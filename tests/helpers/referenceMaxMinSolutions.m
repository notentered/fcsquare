function expected = referenceMaxMinSolutions(a, b, inequalities)
%REFERENCEMAXMINSOLUTIONS Exhaustive finite oracle for small max-min systems.
%   This intentionally does not reuse smaxmin. For max-min systems every
%   extremal coordinate occurs at 0, 1, or a right-hand-side value. The
%   finite grid therefore contains every minimal and maximal solution.

    if nargin < 3
        inequalities = 0;
    end

    a = double(a);
    b = double(b(:));
    if size(a, 1) ~= numel(b)
        error('referenceMaxMinSolutions:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end

    values = unique([0; b; 1]).';
    current = zeros(size(a, 2), 1);
    feasible = zeros(size(a, 2), 0);
    enumerateCoordinate(1);

    expected.exist = ~isempty(feasible);
    if ~expected.exist
        expected.low = zeros(size(a, 2), 0);
        expected.gr = zeros(size(a, 2), 0);
        return;
    end

    feasible = unique(feasible.', 'rows', 'stable').';
    expected.low = extremal(feasible, 'minimal');
    expected.gr = extremal(feasible, 'maximal');

    function enumerateCoordinate(j)
        if j > size(a, 2)
            composed = max(min(a, current.'), [], 2);
            switch inequalities
                case -1
                    isFeasible = all(composed <= b);
                case 0
                    isFeasible = all(composed == b);
                case 1
                    isFeasible = all(composed >= b);
                otherwise
                    error('referenceMaxMinSolutions:InvalidInequality', ...
                        'Inequalities must be -1, 0, or 1.');
            end
            if isFeasible
                feasible(:, end + 1) = current;
            end
            return;
        end

        for value = values
            current(j) = value;
            enumerateCoordinate(j + 1);
        end
    end
end

function result = extremal(candidates, direction)
    keep = true(1, size(candidates, 2));
    for i = 1:size(candidates, 2)
        for j = 1:size(candidates, 2)
            if i == j
                continue;
            end
            switch direction
                case 'minimal'
                    isStrictlyBetter = all(candidates(:, j) <= candidates(:, i)) && ...
                        any(candidates(:, j) < candidates(:, i));
                case 'maximal'
                    isStrictlyBetter = all(candidates(:, j) >= candidates(:, i)) && ...
                        any(candidates(:, j) > candidates(:, i));
            end
            if isStrictlyBetter
                keep(i) = false;
                break;
            end
        end
    end
    result = candidates(:, keep);
end
