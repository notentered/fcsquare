% Solve fuzzy linear systems of equations/inequalities for systems with
% Goguen composition.
% This is the inverse problem for the min-diamond composition, aka
% min - Goguen_implication, aka min - ->P, where x ->P y = (y/x if x > y; 1 otherwize)
function sol = sgoguen(a,b,inequalities,full)
    if ~(size(a,1) == length(b))
        error('Inner matrix dimensions must agree.');
    end
    
    if nargin < 3
        inequalities = 0;
    end

    if nargin < 4
        full = false;
    end

    sol.rows = size(a,1);
    sol.cols = size(a,2);

    sol.help = ones(sol.rows,sol.cols);
    sol.low = zeros(sol.cols, 1);
    sol.ind = zeros(sol.rows, 1);
    
    %Preprocessing
    for j = 1:sol.cols
        for i = 1:sol.rows
            if true || a(i,j) ~= 0
                sol.help(i,j) = a(i,j)*b(i);
            end
        end
    end
    
    %Find the lower solution
    for j = 1:sol.cols
        %Takes the maximal element, for the j-th column of A.
        % col_max = max(sol.help(sol.help(:,j) < 1, j));
        col_max = max(sol.help(:, j));

        if ~isempty(col_max)
            sol.low(j) = col_max;
            
            %All elemnts lower than x_low(j) should be even to 1.
            sol.help(sol.help(:,j) + eps < col_max, j) = 1;
        end
        
        %Next row is because we cannot compare real numbers directly (a
        %presition problem)
        indsolved = find(abs(sol.help(:,j) - sol.low(j)) <= eps);
        sol.ind(indsolved) = sol.ind(indsolved) + 1;
        
        % ToDo: Decide if we are going to rely on "contribution"!
        %       In theory not needed but we still need to apply logic.
        sol.ind(b == 1) = sol.ind(b == 1) + 1;
    end
    sol.help(b == 1, :) = 1; % Do we need this explicitly?
    
    if inequalities == -1 || inequalities == 0
        %Check if the system is consistent
        if ~all(sol.ind)
            sol.exist = false;
            sol.contradict = find(sol.ind' == 0);
            return;
        end
    end
    
    sol.exist = true;
    
    if inequalities == 1
        sol.gr = ones(sol.cols, 1);
        return;
    end
    
    if inequalities == -1
        sol.low = zeros(sol.cols,1);
    end

    if full == false
        sol = sol.low;
        return;
    end
    
    %Domination
    % sol.dominated = find(b==1)';
    sol.dominated = [];
    for i = 2:sol.rows
        if b(i) == 1, continue; end 
        for ii = i-1:-1:1
            if b(ii) == 1, continue; end 
            if isempty(sol.dominated(sol.dominated == ii))
                if b(i) == 0 || b(ii) == 0
                    continue;
                end
                positivej = find(sol.help(i,:) < 1);
                positivejj = find(sol.help(ii,:) < 1);
                if (all(ismember(positivejj,positivej))) && (all(sol.help(ii,positivejj) <= sol.help(i,positivejj)))
                    sol.dominated = [i sol.dominated];
                    break;
                elseif (all(ismember(positivej,positivejj))) && (all(sol.help(i,positivej) <= sol.help(ii,positivej)))
                    sol.dominated = [ii sol.dominated];
                end
            end
        end
    end

    % unique is added here as sometimes some indexes may repeat. Probably
    % need to add it everywhere or find other way to add the indexes
    % Worth checking if unique actually sorts the array as if it does, we
    % may remove the sort() after
    sol.dominated = unique(sol.dominated);

    for i = sort(sol.dominated, 'descend')
        sol.help(i,:) = [];
        b(i) = [];
    end
    
    sol.help_rows = size(sol.help,1);

    %Find greater solutions (depth-first-search)
    if sol.help_rows == 0
        sol.gr = ones(sol.cols,1);
    else
        sol.gr = [];
        marked = zeros(sol.help_rows,1);
        [sortedb,ii] = sort(b + (b==0)*42, 'ascend');
        obtain_gr(ii(1),ones(sol.cols,1),marked);
    end
    
    function obtain_gr(i, gr, marked)
        % for jj = find(sol.help(i,:)<1 | (a(i,:) == 1 & b(i) == 1))
        for jj = find(sol.help(i,:)<1 | (b(i) == 1))
            ngr = gr;
            if ngr(jj) == 1
                ngr(jj) = sol.help(i,jj);
            end
            nmarked = marked;
            nmarked(sol.help(ii,jj)<1 | b(i) == 1) = 1;
            nonmarked = find(nmarked==0);
            if isempty(nonmarked)
                add_gr(ngr);
            else
                obtain_gr(ii(nonmarked(1)),ngr,nmarked);
            end
        end
    end

    function add_gr(gr)
        gr = fuzzyMatrix(gr);
        if ~all(goguen(fuzzyMatrix(a), gr) == goguen(fuzzyMatrix(a), sol.low))
            return;
        end
        % ToDo: If I want to see all *possible* solutions I can just comment the following "for". Probably need to remove this comment later.
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