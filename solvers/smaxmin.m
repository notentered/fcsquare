%SMAXMIN Solve max-min fuzzy systems of equations or inequalities.
%   The implementation deliberately follows the same four stages that the
%   other solvers can adopt later: build bounds, check consistency, extract
%   opposite extremals, and remove dominated duplicates.
function sol = smaxmin(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    if size(a, 1) ~= numel(b)
        error('smaxmin:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('smaxmin:InvalidInequality', ...
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
        restrictingRows = a(:, j) > b;
        if any(restrictingRows)
            upper(j) = min(b(restrictingRows));
        end
    end

    % Stage 2: select the requested boundary and check consistency by
    % direct composition. This also handles B(i)=0 without treating a zero
    % help-matrix entry as "no contribution".
    switch inequalities
        case -1
            sol.gr = upper;
            sol.exist = true;
        case 0
            sol.gr = upper;
            obtained = composeMaxMin(a, sol.gr);
            sol.exist = all(obtained == b);
        case 1
            sol.gr = ones(sol.cols, 1);
            obtained = composeMaxMin(a, sol.gr);
            sol.exist = all(obtained >= b);
    end

    if ~sol.exist
        sol.contradict = find(obtained < b).';
        return;
    end
    sol.gr_inclusive = true(size(sol.gr));

    % Preserve the diagnostic help/contribution representation used by the
    % public result structure. For equations, a contribution must also fit
    % below the greatest solution; for >= inequalities there is no upper
    % restriction other than one.
    for i = 1:sol.rows
        for j = 1:sol.cols
            eligible = a(i, j) >= b(i);
            if inequalities == 0
                eligible = eligible && b(i) <= upper(j);
            end
            if eligible
                sol.help(i, j) = b(i);
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

    % A zero right-hand side has no positive row to cover; zero itself is
    % the unique minimal solution.
    if isempty(sol.low)
        addMinimal(zeros(sol.cols, 1));
    end
    sol.low_inclusive = true(size(sol.low));

    function obtainMinimalCovers(candidate)
        composed = composeMaxMin(a, candidate);
        uncovered = find(composed < b);
        if isempty(uncovered)
            addMinimal(candidate);
            return;
        end

        % Processing the largest unmet level first lets one chosen
        % coordinate cover every compatible lower-level equation.
        [~, position] = max(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) >= b(row))
            next = candidate;
            next(column) = max(next(column), b(row));
            if inequalities == 0 && next(column) > upper(column)
                continue;
            end
            obtainMinimalCovers(next);
        end
    end

    % Stage 4: absorb duplicates and non-minimal covers as they are found.
    function addMinimal(candidate)
        for k = size(sol.low, 2):-1:1
            existing = sol.low(:, k);
            if all(candidate <= existing)
                sol.low(:, k) = [];
            elseif all(existing <= candidate)
                return;
            end
        end
        sol.low(:, end + 1) = candidate;
    end
end

function result = composeMaxMin(a, x)
    result = max(min(a, x.'), [], 2);
end
