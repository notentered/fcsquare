function expected = referenceGodelSolutions(a, b, inequalities)
%REFERENCEGODELSOLUTIONS Independent exact oracle for min-Godel systems.
%   For <= systems, Gödel implication has open branches: when 0<a<=b,
%   I_G(a,x)<=b holds for x<a but not at x=a. Those branches are returned
%   as upper boxes accompanied by a componentwise gr_inclusive mask.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    tolerance = 1e-12;

    if inequalities ~= -1
        criticalValues = cell(1, size(a, 2));
        for j = 1:size(a, 2)
            criticalValues{j} = unique([0; a(:, j); b; 1]).';
        end
        expected = referenceExtremalSolutions( ...
            'godel', a, b, inequalities, criticalValues);
        expected.low_inclusive = true(size(expected.low));
        expected.gr_inclusive = true(size(expected.gr));
        return;
    end

    expected.low = zeros(size(a, 2), 1);
    expected.low_inclusive = true(size(expected.low));
    restrictingRows = find(b < 1 - tolerance);
    impossibleRows = restrictingRows(all(a(restrictingRows, :) <= 0, 2));
    expected.exist = isempty(impossibleRows);
    if ~expected.exist
        expected.gr = zeros(size(a, 2), 0);
        expected.gr_inclusive = false(size(expected.gr));
        return;
    end

    expected.gr = zeros(size(a, 2), 0);
    expected.gr_inclusive = false(size(a, 2), 0);
    enumerateRow(1, ones(size(a, 2), 1), true(size(a, 2), 1));

    function enumerateRow(position, upper, inclusive)
        if position > numel(restrictingRows)
            addBox(upper, inclusive);
            return;
        end

        row = restrictingRows(position);
        for column = find(a(row, :) > 0)
            if a(row, column) > b(row) + tolerance
                limit = b(row);
                limitInclusive = true;
            else
                limit = a(row, column);
                limitInclusive = false;
            end

            nextUpper = upper;
            nextInclusive = inclusive;
            if limit < nextUpper(column) - tolerance
                nextUpper(column) = limit;
                nextInclusive(column) = limitInclusive;
            elseif abs(limit - nextUpper(column)) <= tolerance
                nextInclusive(column) = ...
                    nextInclusive(column) && limitInclusive;
            end
            enumerateRow(position + 1, nextUpper, nextInclusive);
        end
    end

    function addBox(upper, inclusive)
        for k = size(expected.gr, 2):-1:1
            existingUpper = expected.gr(:, k);
            existingInclusive = expected.gr_inclusive(:, k);
            if isContained(existingUpper, existingInclusive, ...
                    upper, inclusive)
                expected.gr(:, k) = [];
                expected.gr_inclusive(:, k) = [];
            elseif isContained(upper, inclusive, ...
                    existingUpper, existingInclusive)
                return;
            end
        end
        expected.gr(:, end + 1) = upper;
        expected.gr_inclusive(:, end + 1) = inclusive;
    end

    function result = isContained(leftUpper, leftInclusive, ...
            rightUpper, rightInclusive)
        strictlyBelow = leftUpper < rightUpper - tolerance;
        equalBound = abs(leftUpper - rightUpper) <= tolerance;
        compatibleEquality = ~leftInclusive | rightInclusive;
        result = all(strictlyBelow | (equalBound & compatibleEquality));
    end
end
