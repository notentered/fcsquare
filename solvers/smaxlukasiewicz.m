%SMAXLUKASIEWICZ Solve max-Lukasiewicz systems or inequalities.
%   The operation-specific upper/contribution level is the Lukasiewicz
%   residual min(1,1-a+b); the four solver stages mirror the other max
%   composition solvers.
function sol = smaxlukasiewicz(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    tolerance = 1e-12;
    if size(a, 1) ~= numel(b)
        error('smaxlukasiewicz:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('smaxlukasiewicz:InvalidInequality', ...
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

    % Stage 1: T_L(a,x)<=b exactly when x<=min(1,1-a+b). The equivalent
    % 1-(a-b) form preserves exact zero-target boundaries 1-a.
    residuals = min(1, 1 - (a - b));
    upper = min(residuals, [], 1).';

    % Stage 2: select the requested monotone boundary and verify it by
    % direct composition.
    switch inequalities
        case -1
            sol.gr = upper;
            sol.exist = true;
        case 0
            sol.gr = upper;
            obtained = composeMaxLukasiewicz(a, sol.gr);
            sol.exist = all(abs(obtained - b) <= tolerance);
        case 1
            sol.gr = ones(sol.cols, 1);
            obtained = composeMaxLukasiewicz(a, sol.gr);
            sol.exist = all(obtained >= b - tolerance);
    end

    if ~sol.exist
        sol.contradict = find(obtained < b - tolerance).';
        return;
    end
    sol.gr_inclusive = true(size(sol.gr));

    % A positive b is attained at x=1-a+b when a>=b.
    for i = 1:sol.rows
        if b(i) <= tolerance
            continue;
        end
        for j = 1:sol.cols
            if a(i, j) < b(i) - tolerance
                continue;
            end
            level = min(1, 1 - (a(i, j) - b(i)));
            eligible = true;
            if inequalities == 0
                eligible = level <= upper(j) + tolerance;
            end
            if eligible
                sol.help(i, j) = level;
                sol.contribution(i, j) = true;
            end
        end
    end
    sol.ind = sum(sol.contribution, 2);

    if ~full
        sol = sol.gr;
        return;
    end

    % Stage 3: <= systems are a down-set. Equations and >= systems require
    % all minimal covers of their positive target rows.
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
        composed = composeMaxLukasiewicz(a, candidate);
        uncovered = find(composed < b - tolerance);
        if isempty(uncovered)
            addMinimal(candidate);
            return;
        end

        [~, position] = max(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) >= b(row) - tolerance)
            level = min(1, 1 - (a(row, column) - b(row)));
            next = candidate;
            next(column) = max(next(column), level);
            if inequalities == 0 && ...
                    next(column) > upper(column) + tolerance
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

function result = composeMaxLukasiewicz(a, x)
    xByRows = repmat(x.', size(a, 1), 1);
    terms = max(0, xByRows - (1 - a));
    result = max(terms, [], 2);
end
