%SMAXPROD Solve max-product fuzzy systems of equations or inequalities.
%   The solver uses the same four stages as smaxmin. Only the operation
%   table changes: contribution levels are the quotients B(i)/A(i,j).
function sol = smaxprod(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    tolerance = 1e-12;
    if size(a, 1) ~= numel(b)
        error('smaxprod:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('smaxprod:InvalidInequality', ...
            'Inequalities must be -1, 0, or 1.');
    end

    sol.rows = size(a, 1);
    sol.cols = size(a, 2);
    sol.help = zeros(sol.rows, sol.cols);
    sol.help_inclusive = true(sol.rows, sol.cols);
    sol.contribution = false(sol.rows, sol.cols);
    sol.ind = zeros(sol.rows, 1);
    sol.dominated = [];
    sol.help_rows = sol.rows;

    % Stage 1: obtain the greatest vector that satisfies A o X <= B.
    upper = ones(sol.cols, 1);
    for j = 1:sol.cols
        positiveRows = a(:, j) > 0;
        if any(positiveRows)
            upper(j) = min([1; b(positiveRows) ./ a(positiveRows, j)]);
        end
    end

    % Stage 2: select the requested boundary and check consistency by
    % direct composition. Zero coefficients never require division.
    switch inequalities
        case -1
            sol.gr = upper;
            sol.exist = true;
        case 0
            sol.gr = upper;
            obtained = composeMaxProduct(a, sol.gr);
            sol.exist = all(abs(obtained - b) <= tolerance);
        case 1
            sol.gr = ones(sol.cols, 1);
            obtained = composeMaxProduct(a, sol.gr);
            sol.exist = all(obtained >= b - tolerance);
    end

    if ~sol.exist
        sol.contradict = find(obtained < b - tolerance).';
        return;
    end
    sol.gr_inclusive = true(size(sol.gr));

    % Diagnostic contribution table. A positive coefficient can attain
    % B(i) exactly when its quotient lies in the fuzzy unit interval.
    for i = 1:sol.rows
        for j = 1:sol.cols
            if a(i, j) <= 0
                continue;
            end
            level = b(i) / a(i, j);
            eligible = level <= 1 + tolerance;
            if inequalities == 0
                eligible = eligible && level <= upper(j) + tolerance;
            end
            if eligible
                sol.help(i, j) = min(max(level, 0), 1);
                sol.contribution(i, j) = true;
            end
        end
    end
    sol.ind = sum(sol.contribution, 2);

    if ~full
        sol = sol.gr;
        return;
    end

    % Stage 3: <= systems are a down-set with zero as their unique minimal
    % solution. Equations and >= systems need all minimal covers.
    if inequalities == -1
        sol.low = zeros(sol.cols, 1);
        sol.low_inclusive = true(size(sol.low));
        return;
    end

    sol.low = zeros(sol.cols, 0);
    obtainMinimalCovers(zeros(sol.cols, 1));
    if isempty(sol.low)
        addMinimal(zeros(sol.cols, 1));
    end
    sol.low_inclusive = true(size(sol.low));

    function obtainMinimalCovers(candidate)
        composed = composeMaxProduct(a, candidate);
        uncovered = find(composed < b - tolerance);
        if isempty(uncovered)
            addMinimal(candidate);
            return;
        end

        [~, position] = max(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) > 0)
            level = b(row) / a(row, column);
            if level > 1 + tolerance
                continue;
            end
            next = candidate;
            next(column) = max(next(column), min(level, 1));
            if inequalities == 0 && next(column) > upper(column) + tolerance
                continue;
            end
            obtainMinimalCovers(next);
        end
    end

    % Stage 4: absorb duplicates and non-minimal covers as they are found.
    function addMinimal(candidate)
        for k = size(sol.low, 2):-1:1
            existing = sol.low(:, k);
            if all(candidate <= existing + tolerance)
                sol.low(:, k) = [];
            elseif all(existing <= candidate + tolerance)
                return;
            end
        end
        sol.low(:, end + 1) = candidate;
    end
end

function result = composeMaxProduct(a, x)
    result = max(a .* x.', [], 2);
end
