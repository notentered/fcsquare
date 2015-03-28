%Solve fuzzy linear systems of equations/inequalities for systems with
%max-product composition.
function sol = smaxprod(a,b,inequalities,full)
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

    sol.help = zeros(sol.rows,sol.cols);
    sol.gr = ones(sol.cols, 1);
    sol.ind = zeros(sol.rows, 1);
    
    %Preprocessing
    for j = 1:sol.cols
        for i = 1:sol.rows
            if a(i,j) >= b(i) && b(i) > 0
                sol.help(i,j) = b(i)/a(i,j);
            end
        end
    end
    
    %Find greatest solution
    for j = 1:sol.cols
        %Takes the minimal element, bigger than 0, for the j-th column of A.
        col_min = min(sol.help(sol.help(:,j) > 0, j));
        
        if ~isempty(col_min)
            %All elemnts bigger than x_gr(j) should be even to 0.
            sol.help(sol.help(:,j) > col_min, j) = 0;
            sol.gr(j) = col_min;
        end
        
        indsolved = find(sol.help(:,j) == sol.gr(j));
        sol.ind(indsolved) = sol.ind(indsolved) + 1;
    end
    
    if inequalities == 0 || inequalities == 1
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
    end
    
    if inequalities == -1
        sol.low = zeros(sol.cols,1);
        return;
    end
    
    if full == false
        sol = sol.gr;
        return;
    end
    
    %Domination
    sol.dominated = [];
    for i = 2:sol.rows
        for ii = i-1:-1:1
            if isempty(sol.dominated(sol.dominated == ii))
                if all(sol.help(ii,:) <= sol.help(i,:))
                    sol.dominated = [i sol.dominated];
                    break;
                elseif all(sol.help(i,:) <= sol.help(ii,:))
                    sol.dominated = [ii sol.dominated];
                end
            end
        end
    end
    for i = sol.dominated
        sol.help(i,:) = [];
    end
    
    sol.help_rows = size(sol.help,1);
    
    %Find lower solution (depth-first-search)
    sol.low = [];
    marked = zeros(sol.help_rows,1);
    obtain_low(1,zeros(sol.cols,1),marked);
    
    function obtain_low(i, low, marked)
        for jj = find(sol.help(i,:)>0)
            nlow = low;
            nlow(jj) = sol.help(i,jj);
            nmarked = marked;
            nmarked(sol.help(:,jj)>0) = 1;
            nonmarked = find(nmarked==0);
            if isempty(nonmarked)
                add_low(nlow);
            else
                obtain_low(nonmarked(1),nlow,nmarked);
            end
        end
    end

    function add_low(low)
        for k = size(sol.low, 2):-1:1
            if all(low <= sol.low(:,k))
                sol.low(:,k) = [];
            elseif all(sol.low(:,k) <= low)
                return;
            end
        end
        sol.low = [sol.low low];
    end
end