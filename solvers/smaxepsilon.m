%SMAXEPSILON Solve max-epsilon fuzzy systems or inequalities.
%   Epsilon is E(a,x)=x for x>a and zero otherwise. Its strict jump makes
%   some >= lower endpoints open; low_inclusive records those endpoints.
function sol = smaxepsilon(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    tolerance = 1e-12;
    if size(a, 1) ~= numel(b)
        error('smaxepsilon:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('smaxepsilon:InvalidInequality', ...
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

    % Stage 1: E(a,x)<=b exactly when x<=max(a,b). Intersecting all rows
    % gives the greatest <= boundary, including b=0 and x=a.
    upper = min(max(a, b), [], 1).';

    % Stage 2: select the requested monotone boundary and verify it by
    % direct composition.
    switch inequalities
        case -1
            sol.gr = upper;
            sol.exist = true;
        case 0
            sol.gr = upper;
            obtained = composeMaxEpsilon(a, sol.gr);
            sol.exist = all(abs(obtained - b) <= tolerance);
        case 1
            sol.gr = ones(sol.cols, 1);
            obtained = composeMaxEpsilon(a, sol.gr);
            sol.exist = all(obtained >= b - tolerance);
    end

    if ~sol.exist
        sol.contradict = find(obtained < b - tolerance).';
        return;
    end
    sol.gr_inclusive = true(size(sol.gr));

    % For equations, b>0 is attained at the closed level x=b only when
    % a<b. For >=, b<=a<1 instead produces the open level x>a.
    for i = 1:sol.rows
        if b(i) <= tolerance
            continue;
        end
        for j = 1:sol.cols
            if inequalities == 1
                if a(i, j) >= 1
                    continue;
                elseif b(i) > a(i, j)
                    level = b(i);
                    levelInclusive = true;
                else
                    level = a(i, j);
                    levelInclusive = false;
                end
                eligible = true;
            else
                level = b(i);
                levelInclusive = true;
                eligible = a(i, j) < b(i);
                if inequalities == 0
                    eligible = eligible && level <= upper(j) + tolerance;
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
        sol = sol.gr;
        return;
    end

    % Stage 3: <= systems are a down-set. Equations need closed minimal
    % covers; >= systems need a union of possibly open lower boxes.
    if inequalities == -1
        sol.low = zeros(sol.cols, 1);
        sol.low_inclusive = true(size(sol.low));
        return;
    end

    sol.low = zeros(sol.cols, 0);
    sol.low_inclusive = false(sol.cols, 0);
    if inequalities == 1
        restrictingRowIndexes = find(b > tolerance);
        enumerateLowerBoxes(1, zeros(sol.cols, 1), true(sol.cols, 1));
    else
        obtainMinimalCovers(zeros(sol.cols, 1));
    end
    if isempty(sol.low)
        addMinimal(zeros(sol.cols, 1), true(sol.cols, 1));
    end

    function enumerateLowerBoxes(position, lower, inclusive)
        if position > numel(restrictingRowIndexes)
            addMinimal(lower, inclusive);
            return;
        end

        row = restrictingRowIndexes(position);
        for column = find(a(row, :) < 1)
            if b(row) > a(row, column)
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
            enumerateLowerBoxes(position + 1, nextLower, nextInclusive);
        end
    end

    function obtainMinimalCovers(candidate)
        composed = composeMaxEpsilon(a, candidate);
        uncovered = find(composed < b - tolerance);
        if isempty(uncovered)
            addMinimal(candidate, true(sol.cols, 1));
            return;
        end

        [~, position] = max(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) < b(row))
            next = candidate;
            next(column) = max(next(column), b(row));
            if next(column) > upper(column) + tolerance
                continue;
            end
            obtainMinimalCovers(next);
        end
    end

    % Stage 4: absorb contained boxes or dominated closed covers.
    function addMinimal(candidate, inclusive)
        for k = size(sol.low, 2):-1:1
            existing = sol.low(:, k);
            existingInclusive = sol.low_inclusive(:, k);
            if isContained(existing, existingInclusive, ...
                    candidate, inclusive)
                sol.low(:, k) = [];
                sol.low_inclusive(:, k) = [];
            elseif isContained(candidate, inclusive, ...
                    existing, existingInclusive)
                return;
            end
        end
        sol.low(:, end + 1) = candidate;
        sol.low_inclusive(:, end + 1) = inclusive;
    end

    function result = isContained(leftLower, leftInclusive, ...
            rightLower, rightInclusive)
        strictlyAbove = leftLower > rightLower + tolerance;
        equalBound = abs(leftLower - rightLower) <= tolerance;
        compatibleEquality = ~leftInclusive | rightInclusive;
        result = all(strictlyAbove | (equalBound & compatibleEquality));
    end
end

function result = composeMaxEpsilon(a, x)
    xByRows = repmat(x.', size(a, 1), 1);
    terms = zeros(size(a));
    active = xByRows > a;
    terms(active) = xByRows(active);
    result = max(terms, [], 2);
end
