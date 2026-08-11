%SMINMAX Solve min-max fuzzy systems of equations or inequalities.
%   This is the order-dual of smaxmin and intentionally uses the same four
%   stages: build bounds, check consistency, extract opposite extremals,
%   and remove dominated duplicates.
function sol = sminmax(a, b, inequalities, full)
    if nargin < 3
        inequalities = 0;
    end
    if nargin < 4
        full = false;
    end

    b = b(:);
    if size(a, 1) ~= numel(b)
        error('sminmax:DimensionMismatch', ...
            'The number of rows in A must equal the length of B.');
    end
    if ~ismember(inequalities, [-1 0 1])
        error('sminmax:InvalidInequality', ...
            'Inequalities must be -1, 0, or 1.');
    end

    sol.rows = size(a, 1);
    sol.cols = size(a, 2);
    sol.help = ones(sol.rows, sol.cols);
    sol.contribution = false(sol.rows, sol.cols);
    sol.ind = zeros(sol.rows, 1);
    sol.dominated = [];
    sol.help_rows = sol.rows;

    % Stage 1: obtain the least vector that satisfies A o X >= B.
    lower = zeros(sol.cols, 1);
    for j = 1:sol.cols
        restrictingRows = a(:, j) < b;
        if any(restrictingRows)
            lower(j) = max(b(restrictingRows));
        end
    end

    % Stage 2: select the requested boundary and check consistency by
    % direct composition.
    switch inequalities
        case -1
            sol.low = zeros(sol.cols, 1);
            obtained = composeMinMax(a, sol.low);
            sol.exist = all(obtained <= b);
        case 0
            sol.low = lower;
            obtained = composeMinMax(a, sol.low);
            sol.exist = all(obtained == b);
        case 1
            sol.low = lower;
            sol.exist = true;
    end

    if ~sol.exist
        sol.contradict = find(obtained > b).';
        return;
    end

    % Preserve the public diagnostic representation. For equations, a
    % contribution must fit above the least solution; <= inequalities have
    % no additional lower restriction.
    for i = 1:sol.rows
        for j = 1:sol.cols
            eligible = a(i, j) <= b(i);
            if inequalities == 0
                eligible = eligible && b(i) >= lower(j);
            end
            if eligible
                sol.help(i, j) = b(i);
                sol.contribution(i, j) = true;
            end
        end
    end
    sol.ind = sum(sol.contribution, 2);

    if ~full
        sol = sol.low;
        return;
    end

    % Stage 3: >= systems are an up-set with one as their unique maximal
    % solution. Equations and <= systems need all maximal covers.
    if inequalities == 1
        sol.gr = ones(sol.cols, 1);
        return;
    end

    sol.gr = zeros(sol.cols, 0);
    obtainMaximalCovers(ones(sol.cols, 1));

    % If one already satisfies every row, it is the unique maximal vector.
    if isempty(sol.gr)
        addMaximal(ones(sol.cols, 1));
    end

    function obtainMaximalCovers(candidate)
        composed = composeMinMax(a, candidate);
        uncovered = find(composed > b);
        if isempty(uncovered)
            addMaximal(candidate);
            return;
        end

        % Processing the smallest unmet level first lets one chosen
        % coordinate cover every compatible higher-level equation.
        [~, position] = min(b(uncovered));
        row = uncovered(position);
        for column = find(a(row, :) <= b(row))
            next = candidate;
            next(column) = min(next(column), b(row));
            if inequalities == 0 && next(column) < lower(column)
                continue;
            end
            obtainMaximalCovers(next);
        end
    end

    % Stage 4: absorb duplicates and non-maximal covers as they are found.
    function addMaximal(candidate)
        for k = size(sol.gr, 2):-1:1
            existing = sol.gr(:, k);
            if all(candidate >= existing)
                sol.gr(:, k) = [];
            elseif all(existing >= candidate)
                return;
            end
        end
        sol.gr(:, end + 1) = candidate;
    end
end

function result = composeMinMax(a, x)
    result = min(max(a, x.'), [], 2);
end
