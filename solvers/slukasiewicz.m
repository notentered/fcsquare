%Solve fuzzy linear systems of equations/inequalities for systems with
%Lukasiewicz composition.
function sol = slukasiewicz(a,b,inequalities,full)
    if ~(size(a,1) == length(b))
        error('Inner matrix dimensions must agree.');
    end;
    
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
            if 1 - a(i,j) <= b(i) + eps
                sol.help(i,j) = a(i,j) + b(i) - 1;
            end
        end
    end
    
    %Find the lower solution
    for j = 1:sol.cols
        %Takes the maximal element, for the j-th column of A.
        col_max = max(sol.help(sol.help(:,j) < 1, j));
        
        if ~isempty(col_max)
            sol.low(j) = col_max;
            
            %All elemnts lower than x_low(j) should be even to 1.
            sol.help(sol.help(:,j) + eps < col_max, j) = 1;
        end
        
        %Next row is because we cannot compare real numbers directly (a
        %presition problem)
        indsolved = find(abs(sol.help(:,j) - sol.low(j)) <= eps);
        sol.ind(indsolved) = sol.ind(indsolved) + 1;
    end
    
    if inequalities == -1 || inequalities == 0
        %Check if the system is consistent
        if ~all(sol.ind)
            sol.exist = false;
            sol.contradict = find(sol.ind' == 0);
            return;
        end;
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
    sol.dominated = find(b==1);
    for i = 2:sol.rows
        for ii = i-1:-1:1
            if isempty(sol.dominated(sol.dominated == ii))
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
    for i = sort(sol.dominated, 'descend')
       sol.help(i,:) = [];
    end

    sol.help_rows = size(sol.help,1);
    
    %Find greater solutions (depth-first-search)
    if sol.help_rows == 0
        sol.gr = ones(sol.cols,1);
    else
        sol.gr = [];
        marked = zeros(sol.help_rows,1);
        obtain_gr(1,ones(sol.cols,1),marked);
    end
    
    function obtain_gr(i, gr, marked)
        for jj = find(sol.help(i,:)<1)
            ngr = gr;
            ngr(jj) = sol.help(i,jj);
            nmarked = marked;
            nmarked(sol.help(:,jj)<1) = 1;
            nonmarked = find(nmarked==0);
            if isempty(nonmarked)
                add_gr(ngr);
            else
                obtain_gr(nonmarked(1),ngr,nmarked);
            end
        end
    end

    function add_gr(gr)
        for k = 1:size(sol.gr, 2)
            if all(gr <= sol.gr(:,k))
                sol.gr(:,k) = [];
            elseif all(sol.gr(:,k) <= gr)
                return;
            end
        end
        sol.gr = [sol.gr gr];
    end
end