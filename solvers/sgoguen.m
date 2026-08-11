%SGOGUEN Solve min-Goguen fuzzy systems of equations or inequalities.
%   The operation-specific boundary is a(i,j)*b(i); the surrounding four
%   stages intentionally mirror the other inverse solvers.
function sol = sgoguen(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    tolerance = 1e-12;
    if size(a, 1) ~= numel(b)
        error('sgoguen:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('sgoguen:InvalidInequality', ...
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

    % Stage 1: I_P(a,x)>=b exactly when x>=a*b, also for a=0.
    lower = max(a .* b, [], 1).';

    % Stage 2: select the monotone boundary and verify it directly. A row
    % containing only zero coefficients always composes to one.
    switch inequalities
        case -1
            sol.low = zeros(sol.cols, 1);
            obtained = composeGoguen(a, sol.low);
            sol.exist = all(obtained <= b + tolerance);
        case 0
            sol.low = lower;
            obtained = composeGoguen(a, sol.low);
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

    % A positive coefficient attains b<1 at the closed level a*b.
    for i = 1:sol.rows
        if b(i) >= 1 - tolerance
            continue;
        end
        for j = 1:sol.cols
            if a(i, j) <= 0
                continue;
            end
            level = a(i, j) * b(i);
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
    % all maximal covers formed from the a(i,j)*b(i) levels.
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
        composed = composeGoguen(a, candidate);
        uncovered = find(composed > b + tolerance);
        if isempty(uncovered)
            addMaximal(candidate);
            return;
        end

        [~, position] = min(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) > 0)
            level = a(row, column) * b(row);
            next = candidate;
            next(column) = min(next(column), level);
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

function result = composeGoguen(a, x)
    xByRows = repmat(x.', size(a, 1), 1);
    implications = ones(size(a));
    belowAntecedent = a > xByRows;
    implications(belowAntecedent) = ...
        xByRows(belowAntecedent) ./ a(belowAntecedent);
    result = min(implications, [], 2);
end
