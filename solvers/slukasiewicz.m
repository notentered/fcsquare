%SLUKASIEWICZ Solve min-Lukasiewicz systems or inequalities.
%   The operation-specific boundary is max(0,a(i,j)+b(i)-1); the four
%   solver stages otherwise mirror the other monotone inverse solvers.
function sol = slukasiewicz(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    tolerance = 1e-12;
    if size(a, 1) ~= numel(b)
        error('slukasiewicz:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('slukasiewicz:InvalidInequality', ...
            'Inequalities must be -1, 0, or 1.');
    end

    sol.rows = size(a, 1);
    sol.cols = size(a, 2);
    sol.help = ones(sol.rows, sol.cols);
    sol.help_inclusive = true(sol.rows, sol.cols);
    sol.contribution = false(sol.rows, sol.cols);
    sol.ind = zeros(sol.rows, 1);
    sol.dominated = [];
    sol.help_rows = sol.rows;

    % Stage 1: I_L(a,x)>=b exactly when x>=max(0,a+b-1).
    levels = max(0, a + b - 1);
    lower = max(levels, [], 1).';

    % Stage 2: select the requested monotone boundary and verify it by
    % direct composition. This also handles zero coefficients and b=1.
    switch inequalities
        case -1
            sol.low = zeros(sol.cols, 1);
            obtained = composeLukasiewicz(a, sol.low);
            sol.exist = all(obtained <= b + tolerance);
        case 0
            sol.low = lower;
            obtained = composeLukasiewicz(a, sol.low);
            sol.exist = all(abs(obtained - b) <= tolerance);
        case 1
            sol.low = lower;
            sol.exist = true;
    end

    if ~sol.exist
        sol.contradict = find(obtained > b + tolerance).';
        return;
    end
    sol.low_inclusive = true(size(sol.low));

    % A b<1 level is attainable only when a+b-1 lies in [0,1].
    for i = 1:sol.rows
        if b(i) >= 1 - tolerance
            continue;
        end
        for j = 1:sol.cols
            rawLevel = a(i, j) + b(i) - 1;
            if rawLevel < -tolerance
                continue;
            end
            level = max(0, rawLevel);
            eligible = true;
            if inequalities == 0
                eligible = level >= lower(j) - tolerance;
            end
            if eligible
                sol.help(i, j) = level;
                sol.contribution(i, j) = true;
            end
        end
    end
    sol.ind = sum(sol.contribution, 2);

    if ~full
        sol = sol.low;
        return;
    end

    % Stage 3: >= systems are an up-set. Equations and <= systems require
    % all maximal covers formed from their attainable levels.
    if inequalities == 1
        sol.gr = ones(sol.cols, 1);
        sol.gr_inclusive = true(size(sol.gr));
        return;
    end

    sol.gr = zeros(sol.cols, 0);
    obtainMaximalCovers(ones(sol.cols, 1));
    if isempty(sol.gr)
        addMaximal(ones(sol.cols, 1));
    end
    sol.gr_inclusive = true(size(sol.gr));

    function obtainMaximalCovers(candidate)
        composed = composeLukasiewicz(a, candidate);
        uncovered = find(composed > b + tolerance);
        if isempty(uncovered)
            addMaximal(candidate);
            return;
        end

        [~, position] = min(b(uncovered));
        row = uncovered(position);
        for column = 1:sol.cols
            rawLevel = a(row, column) + b(row) - 1;
            if rawLevel < -tolerance
                continue;
            end
            next = candidate;
            next(column) = min(next(column), max(0, rawLevel));
            if inequalities == 0 && ...
                    next(column) < lower(column) - tolerance
                continue;
            end
            obtainMaximalCovers(next);
        end
    end

    % Stage 4: absorb duplicates and non-maximal covers as they are found.
    function addMaximal(candidate)
        for k = size(sol.gr, 2):-1:1
            existing = sol.gr(:, k);
            if all(candidate >= existing - tolerance)
                sol.gr(:, k) = [];
            elseif all(existing >= candidate - tolerance)
                return;
            end
        end
        sol.gr(:, end + 1) = candidate;
    end
end

function result = composeLukasiewicz(a, x)
    xByRows = repmat(x.', size(a, 1), 1);
    implications = min(1, 1 - a + xByRows);
    result = min(implications, [], 2);
end
