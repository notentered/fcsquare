%Solve fuzzy linear systems of equations/inequalities for systems with
%max-min composition.
% ToDo: on future refactoring, start with maxmin & sgodel in parallel 
function sol = smaxmin(a,b,inequalities,full)
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

    sol.help = zeros(sol.rows,sol.cols);
    sol.contribution = false(sol.rows, sol.cols);
    sol.gr = ones(sol.cols, 1);
    sol.ind = zeros(sol.rows, 1);
    
    %Preprocessing
    for j = 1:sol.cols
        for i = 1:sol.rows
            if a(i,j) >= b(i)
                sol.help(i,j) = b(i);
                sol.contribution(i,j) = true;
            end
        end
    end

    %Find greatest solution
    for j = 1:sol.cols
        %Takes the minimal G type element, for the j-th column of A.
        [sortedb,ii] = sort(b);
        col_min = 1;
        for i = ii'
            if (sol.contribution(i,j) == true) && (a(i,j) ~= b(i))
                col_min = sol.help(i,j);
                break;
            end
        end
        
        %All elemnts bigger than x_gr(j) should be even to 0.
        mask = sol.help(:,j) > col_min;
        sol.help(mask, j) = 0;
        sol.contribution(mask, j) = false;
        
        sol.gr(j) = col_min;
        
        indsolved = find(sol.contribution(:,j) == true);
        sol.ind(indsolved) = sol.ind(indsolved) + 1;
    end
    
    if inequalities == 0 || inequalities == 1
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
                positivej  = find(sol.contribution(i,:) == true);
                positivejj = find(sol.contribution(ii,:) == true);
                if (all(ismember(positivejj,positivej))) && (all(sol.help(ii,positivejj) >= sol.help(i,positivejj)))
                    sol.dominated = [i sol.dominated];
                    break;
                elseif (all(ismember(positivej,positivejj))) && (all(sol.help(i,positivej) >= sol.help(ii,positivej)))
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
    
    %Find lower solution (depth-first-search)
    sol.low = [];
    marked = zeros(sol.help_rows,1);
    [sortedb,ii] = sort(b, 'descend');
    obtain_low(ii(1),zeros(sol.cols,1),marked);
    
    function obtain_low(i, low, marked)
        for jj = find(sol.contribution(i,:) == true)
            nlow = low;
            nlow(jj) = sol.help(i,jj);
            nmarked = marked;
            nmarked(sol.contribution(ii,jj) == true) = 1;
            nonmarked = find(nmarked==0);
            if isempty(nonmarked)
                add_low(nlow);
            else
                obtain_low(ii(nonmarked(1)),nlow,nmarked);
            end
        end
    end

    function add_low(low)
        low = fuzzyMatrix(low);
        for k = size(sol.low, 2):-1:1
            low_j = fuzzyMatrix(sol.low(:,k));
            if all(low <= low_j)
                sol.low(:,k) = [];
            elseif all(low_j <= low)
                return;
            end
        end
        sol.low = [sol.low low];
    end
end