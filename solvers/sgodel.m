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
            obtained = composeGodel(a, sol.low);
            sol.exist = all(obtained <= b + tolerance);
        case 0
            sol.low = lower;
            obtained = composeGodel(a, sol.low);
            sol.exist = all(abs(obtained - b) <= tolerance);
        case 1
            sol.low = lower;
            sol.exist = true;
    end

    if ~sol.exist
        sol.contradict = find(obtained > b + tolerance).';
        return;
    end

    % A row with b<1 can attain b at column j precisely by setting x_j=b
    % when a(i,j)>b. Equations additionally require that level to stay
    % above their already-established least solution.
    for i = 1:sol.rows
        if b(i) >= 1 - tolerance
            continue;
        end
        for j = 1:sol.cols
            eligible = a(i, j) > b(i) + tolerance;
            if inequalities == 0
                eligible = eligible && b(i) >= lower(j) - tolerance;
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

    % Stage 3: >= systems are an up-set with one as the unique maximal
    % vector. Equations and <= systems require all maximal row covers.
    if inequalities == 1
        sol.gr = ones(sol.cols, 1);
        return;
    end

    sol.gr = zeros(sol.cols, 0);
    obtainMaximalCovers(ones(sol.cols, 1));
    if isempty(sol.gr)
        addMaximal(ones(sol.cols, 1));
    end

    function obtainMaximalCovers(candidate)
        composed = composeGodel(a, candidate);
        uncovered = find(composed > b + tolerance);
        if isempty(uncovered)
            addMaximal(candidate);
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

function result = composeGodel(a, x)
    xByRows = repmat(x.', size(a, 1), 1);
    implications = ones(size(a));
    belowAntecedent = a > xByRows;
    implications(belowAntecedent) = xByRows(belowAntecedent);
    result = min(implications, [], 2);
end
