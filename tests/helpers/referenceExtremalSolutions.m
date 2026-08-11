function expected = referenceExtremalSolutions(composition, a, b, inequalities, criticalValues)
%REFERENCEEXTREMALSOLUTIONS Exhaustive solver oracle for small systems.
%   The caller supplies the mathematically sufficient finite values for
%   each coordinate. Composition is evaluated directly; no inverse solver
%   code or solver-specific help matrix is reused.

    if nargin < 4
        inequalities = 0;
    end

    a = fuzzyMatrix(a);
    b = double(b(:));
    if size(a, 1) ~= numel(b)
        error('referenceExtremalSolutions:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~iscell(criticalValues)
        criticalValues = repmat({criticalValues}, 1, size(a, 2));
    end
    if numel(criticalValues) ~= size(a, 2)
        error('referenceExtremalSolutions:InvalidCriticalValues', ...
            'Critical values must be supplied for every unknown.');
    end

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
    expected.low = findExtremal(feasible, 'minimal');
    expected.gr = findExtremal(feasible, 'maximal');

    function enumerateCoordinate(j)
        if j > size(a, 2)
            composed = double(feval(composition, a, fuzzyMatrix(current)));
            switch inequalities
                case -1
                    isFeasible = all(composed <= b);
                case 0
                    isFeasible = all(composed == b);
                case 1
                    isFeasible = all(composed >= b);
                otherwise
                    error('referenceExtremalSolutions:InvalidInequality', ...
                        'Inequalities must be -1, 0, or 1.');
            end
            if isFeasible
                feasible(:, end + 1) = current;
            end
            return;
        end

        for value = criticalValues{j}
            current(j) = value;
            enumerateCoordinate(j + 1);
        end
    end
end

function result = findExtremal(candidates, direction)
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
