%SGODEL Solve min-Godel fuzzy systems of equations or inequalities.
%   The solver follows the common four-stage inverse-solver structure:
%   build the monotone boundary, verify it by direct composition, enumerate
%   the opposite extremal covers, and absorb dominated duplicates.
function sol = sgodel(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    tolerance = 1e-12;
    if size(a, 1) ~= numel(b)
        error('sgodel:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('sgodel:InvalidInequality', ...
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

    % Stage 1: I_G(a,x) >= b exactly when x >= min(a,b). Therefore the
    % componentwise maximum below is the least vector satisfying every
    % >= constraint, including the b=1 boundary.
    lower = max(min(a, b), [], 1).';

    % Stage 2: select the requested monotone boundary and verify it by
    % direct composition. Equations can only fail above B at their least
    % >= boundary; <= systems can only fail above B at zero.
    switch inequalities
        case -1
            sol.low = zeros(sol.cols, 1);
            restrictingRows = b < 1 - tolerance;
            impossibleRows = restrictingRows & all(a <= 0, 2);
            sol.exist = ~any(impossibleRows);
        case 0
            sol.low = lower;
            obtained = composeGodel(a, sol.low);
            sol.exist = all(abs(obtained - b) <= tolerance);
        case 1
            sol.low = lower;
            sol.exist = true;
    end

    if ~sol.exist
        if inequalities == -1
            sol.contradict = find(impossibleRows).';
        else
            sol.contradict = find(obtained > b + tolerance).';
        end
        return;
    end

    sol.low_inclusive = true(size(sol.low));

    % A row with b<1 attains b at x_j=b when a(i,j)>b. For <= only,
    % 0<a(i,j)<=b adds the open alternative x_j<a(i,j).
    for i = 1:sol.rows
        if b(i) >= 1 - tolerance
            continue;
        end
        for j = 1:sol.cols
            if inequalities == -1
                eligible = a(i, j) > 0;
                if a(i, j) > b(i) + tolerance
                    level = b(i);
                    levelInclusive = true;
                else
                    level = a(i, j);
                    levelInclusive = false;
                end
            else
                eligible = a(i, j) > b(i) + tolerance;
                level = b(i);
                levelInclusive = true;
                if inequalities == 0
                    eligible = eligible && b(i) >= lower(j) - tolerance;
                end
            end
            if eligible
                sol.help(i, j) = level;
                sol.help_inclusive(i, j) = levelInclusive;
                sol.contribution(i, j) = true;
            end
        end
    end
    sol.ind = sum(sol.contribution, 2);

    if ~full
        sol = sol.low;
        return;
    end

    % Stage 3: >= systems are an up-set with one as the unique maximal
    % vector. Equations and <= systems require all maximal row covers.
    if inequalities == 1
        sol.gr = ones(sol.cols, 1);
        sol.gr_inclusive = true(size(sol.gr));
        return;
    end

    sol.gr = zeros(sol.cols, 0);
    sol.gr_inclusive = false(sol.cols, 0);
    if inequalities == -1
        restrictingRowIndexes = find(b < 1 - tolerance);
        enumerateUpperBoxes(1, ones(sol.cols, 1), true(sol.cols, 1));
    else
        obtainMaximalCovers(ones(sol.cols, 1));
    end
    if isempty(sol.gr)
        addMaximal(ones(sol.cols, 1), true(sol.cols, 1));
    end

    % Gödel <= systems are a union of upper boxes. The discontinuity at
    % x=a makes a box endpoint open when 0<a<=b. Keeping that mask avoids
    % claiming a non-solution endpoint while retaining the complete set.
    function enumerateUpperBoxes(position, upper, inclusive)
        if position > numel(restrictingRowIndexes)
            addMaximal(upper, inclusive);
            return;
        end

        row = restrictingRowIndexes(position);
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
            enumerateUpperBoxes(position + 1, nextUpper, nextInclusive);
        end
    end

    function obtainMaximalCovers(candidate)
        composed = composeGodel(a, candidate);
        uncovered = find(composed > b + tolerance);
        if isempty(uncovered)
            addMaximal(candidate, true(sol.cols, 1));
            return;
        end

        % Reducing a coordinate to the smallest unmet row level can cover
        % that row and every compatible row at the same or a higher level.
        [~, position] = min(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) > b(row) + tolerance)
            next = candidate;
            next(column) = min(next(column), b(row));
            if inequalities == 0 && ...
                    next(column) < lower(column) - tolerance
                continue;
            end
            obtainMaximalCovers(next);
        end
    end

    % Stage 4: absorb duplicates and non-maximal covers as they are found.
    function addMaximal(candidate, inclusive)
        for k = size(sol.gr, 2):-1:1
            existing = sol.gr(:, k);
            existingInclusive = sol.gr_inclusive(:, k);
            if isContained(existing, existingInclusive, ...
                    candidate, inclusive)
                sol.gr(:, k) = [];
                sol.gr_inclusive(:, k) = [];
            elseif isContained(candidate, inclusive, ...
                    existing, existingInclusive)
                return;
            end
        end
        sol.gr(:, end + 1) = candidate;
        sol.gr_inclusive(:, end + 1) = inclusive;
    end

    function result = isContained(leftUpper, leftInclusive, ...
            rightUpper, rightInclusive)
        strictlyBelow = leftUpper < rightUpper - tolerance;
        equalBound = abs(leftUpper - rightUpper) <= tolerance;
        compatibleEquality = ~leftInclusive | rightInclusive;
        result = all(strictlyBelow | (equalBound & compatibleEquality));
    end
end

function result = composeGodel(a, x)
    xByRows = repmat(x.', size(a, 1), 1);
    implications = ones(size(a));
    belowAntecedent = a > xByRows;
    implications(belowAntecedent) = xByRows(belowAntecedent);
    result = min(implications, [], 2);
end
