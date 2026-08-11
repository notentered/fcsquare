function expected = referenceMaxEpsilonSolutions(a, b, inequalities)
%REFERENCEMAXEPSILONSOLUTIONS Exact oracle for max-epsilon systems.
%   >= systems can contain open lower boxes when b<=a<1. Those boxes are
%   returned with a componentwise low_inclusive mask.
    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    tolerance = 1e-12;

    if inequalities ~= 1
        criticalValues = cell(1, size(a, 2));
        for j = 1:size(a, 2)
            criticalValues{j} = unique([0; a(:, j); b; 1]).';
        end
        expected = referenceExtremalSolutions( ...
            'maxepsilon', a, b, inequalities, criticalValues);
        expected.low_inclusive = true(size(expected.low));
        expected.gr_inclusive = true(size(expected.gr));
        return;
    end

    expected.gr = ones(size(a, 2), 1);
    expected.gr_inclusive = true(size(expected.gr));
    restrictingRows = find(b > tolerance);
    impossibleRows = restrictingRows(all(a(restrictingRows, :) >= 1, 2));
    expected.exist = isempty(impossibleRows);
    if ~expected.exist
        expected.low = zeros(size(a, 2), 0);
        expected.low_inclusive = false(size(expected.low));
        return;
    end

    expected.low = zeros(size(a, 2), 0);
    expected.low_inclusive = false(size(a, 2), 0);
    enumerateRow(1, zeros(size(a, 2), 1), true(size(a, 2), 1));

    function enumerateRow(position, lower, inclusive)
        if position > numel(restrictingRows)
            addBox(lower, inclusive);
            return;
        end

        row = restrictingRows(position);
        for column = find(a(row, :) < 1)
            if b(row) > a(row, column) + tolerance
                limit = b(row);
                limitInclusive = true;
            else
                limit = a(row, column);
                limitInclusive = false;
            end

            nextLower = lower;
            nextInclusive = inclusive;
            if limit > nextLower(column) + tolerance
                nextLower(column) = limit;
                nextInclusive(column) = limitInclusive;
            elseif abs(limit - nextLower(column)) <= tolerance
                nextInclusive(column) = ...
                    nextInclusive(column) && limitInclusive;
            end
            enumerateRow(position + 1, nextLower, nextInclusive);
        end
    end

    function addBox(lower, inclusive)
        for k = size(expected.low, 2):-1:1
            existingLower = expected.low(:, k);
            existingInclusive = expected.low_inclusive(:, k);
            if isContained(existingLower, existingInclusive, ...
                    lower, inclusive)
                expected.low(:, k) = [];
                expected.low_inclusive(:, k) = [];
            elseif isContained(lower, inclusive, ...
                    existingLower, existingInclusive)
                return;
            end
        end
        expected.low(:, end + 1) = lower;
        expected.low_inclusive(:, end + 1) = inclusive;
    end

    function result = isContained(leftLower, leftInclusive, ...
            rightLower, rightInclusive)
        strictlyAbove = leftLower > rightLower + tolerance;
        equalBound = abs(leftLower - rightLower) <= tolerance;
        compatibleEquality = ~leftInclusive | rightInclusive;
        result = all(strictlyAbove | (equalBound & compatibleEquality));
    end
end
