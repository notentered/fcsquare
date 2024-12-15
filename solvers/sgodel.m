% Solve fuzzy linear systems of equations/inequalities for systems with
% Godel composition.
% This is the inverse problem for the min-alpha composition, aka
% min - Godel_implication, aka min - ->G, where x ->G y = (y if x > y; 1 otherwize)

function sol = sgodel(a,b,inequalities,full)
    if ~(size(a,1) == length(b))
        error('Inner matrix dimensions must agree.');
    end

    sol.rows = size(a,1);
    sol.cols = size(a,2);

    sol.help = ones(sol.rows,sol.cols);
    sol.contribution = false(sol.rows, sol.cols);
    sol.low = zeros(sol.cols, 1);
    sol.ind = zeros(sol.rows, 1);
    
    % Preprocessing
    % ToDo: We actually may need to have two separate preprocessing steps everywhere
    %       One to set the help values and one to set the contributing elements.
    % ToDo: "contribution" may not be the best strategy here. We actually
    %       have intervals in which x_i can follow. So low, gr will take
    %       one of its ends.
    % ToDo: The help matrix start to looks a bit messy again. We pun in
    %       there the possible values for the lowest solution, while we
    %       know that for the upper solutions we can just use 1. It will be
    %       vise-versa in max-something case. How about if we use two
    %       matrices instead - one for potential lower values and one for
    %       potential upper values? Or can we make this calculations "on
    %       the fly"?
    for j = 1:sol.cols
        for i = 1:sol.rows
            if a(i,j) <= b(i)
                if b(i) == 1
                    sol.contribution(i,j) = true;
                else
                    sol.contribution(i,j) = false;
                end
                sol.help(i,j) = a(i,j);
            else
                sol.contribution(i,j) = true;
                sol.help(i,j) = b(i);
            end
            
        end
    end

    % Interesting edge case. If b == 1, then we can take any maximal a_ij for x_i
    % ToDo: It may happen to have similar cases in the other compositions
    %       which we are covering with other logic. E.g. the previous usage
    %       of E-type coefficients.
    % ToDo: Maybe consider general edge cases handling
    % ToDo: Maybe we just need to define intervals for every x,
    %       non-contradicting the required b

    if (nargin >= 3) && (inequalities == true)
        sol.low = zeros(rows,1);
    else
        % Find the lower solution
        for j = 1:sol.cols
            % Takes the maximal element, for the j-th column of A.
            % col_max = max(sol.help(sol.contribution(:,j), j));
            col_max = max(sol.help(:, j));
            
            if ~isempty(col_max)
                sol.low(j) = col_max;                
                mask = sol.contribution(:,j) & (sol.help(:,j) + eps < col_max);
                sol.help(mask, j) = col_max;
                sol.contribution(mask & (b ~= 1), j) = false;
                sol.help((b == 1), j) = 1;
            else
                sol.low(j) = max(sol.help(:,j));
            end
            
            % Next row is because we cannot compare real numbers directly (a
            % presition problem)
            % ToDo: We can now use precision aware comparison if we compare
            %       instances of fuzzyMatrix
            indsolved = find(sol.contribution(:,j) & (abs(sol.help(:,j) - sol.low(j)) <= eps));
            sol.ind(indsolved) = sol.ind(indsolved) + 1;
        end
        sol.ind(b == 1) = sol.ind(b == 1) + 1;
    end    
    
    % Check if the system is consistent
    if ~all(sol.ind)
        sol.exist = false;
        sol.contradict = find(sol.ind' == 0);
        return;
    end
    
    sol.exist = true;
    
    if (nargin >=4) && (full == false)
        sol = sol.low;
        return;
    end

    % Domination
    sol.dominated = [];
    for i = 2:sol.rows
        if b(i) == 1, continue; end 
        for ii = i-1:-1:1
            if b(ii) == 1, continue; end 
            if isempty(sol.dominated(sol.dominated == ii))
                positivej  = find(sol.contribution(i,:) == true);
                positivejj = find(sol.contribution(ii,:) == true);
                if (all(ismember(positivejj,positivej))) && (all(sol.help(ii,positivejj) <= sol.help(i,positivejj)))
                    sol.dominated = [i sol.dominated];
                    break;
                elseif (all(ismember(positivej,positivejj))) && (all(sol.help(i,positivej) <= sol.help(ii,positivej)))
                    sol.dominated = [ii sol.dominated];
                end
            end
        end
    end
    
    for i = sort(sol.dominated, 'descend')
       sol.help(i,:) = [];
       sol.contribution(i,:) = [];
       b(i) = [];
    end

    sol.help_rows = size(sol.help,1);
    
    % Find greater solution (depth-first-search)
    if sol.help_rows == 0
        sol.gr = ones(sol.cols,1);
    else
        sol.gr = [];
        marked = zeros(sol.help_rows,1);
        [sortedb,ii] = sort(b, 'ascend');
        obtain_gr(ii(1),ones(sol.cols,1),marked);
    end
    
    function obtain_gr(i, gr, marked)
        for jj = find(sol.contribution(i,:))
            ngr = gr;
            ngr(jj) = sol.help(i,jj);
            nmarked = marked;
            nmarked(sol.contribution(:,jj)) = 1;
            nonmarked = find(nmarked==0);
            if isempty(nonmarked)
                add_gr(ngr);
            else
                obtain_gr(nonmarked(1),ngr,nmarked);
            end
        end
    end

    function add_gr(gr)
        gr = fuzzyMatrix(gr);
        for k = size(sol.gr, 2):-1:1
            gr_j = fuzzyMatrix(sol.gr(:,k));
            if all(gr >= gr_j)
                sol.gr(:,k) = [];
            elseif all(gr_j >= gr)
                return;
            end
        end
        sol.gr = [sol.gr gr];
    end
end