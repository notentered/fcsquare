%Solve fuzzy linear systems of equations/inequalities for systems with
%max-product composition.
function sol = smaxprod(a,b,inequalities,full)
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

    sol.help = fuzzyMatrix(zeros(sol.rows,sol.cols));
    sol.contribution = false(sol.rows,sol.cols);
    sol.gr = fuzzyMatrix(ones(sol.cols, 1));
    sol.ind = zeros(sol.rows, 1);
    
    %Preprocessing
    for j = 1:sol.cols
        for i = 1:sol.rows
            % ToDo: Investigate all edge colutions for all operations,
            % where x_i can be some interval and develop universal
            % solution. E.g. Here if both a_ij and b_j are == 0, then the
            % corresponding x_j can be whatever between 0 and 1. We take 1
            % in the gr and 0 in low. Therefore here we assign 1 to the
            % help matrix to produce the correct gr, but later we make them
            % explicitly 0, to produce the right low(s)

            % ToDo: Add explicit examples in the tests with A = [0 0 0;...]
            % and B = [0; 0; ...], and the same with everywhere "1"
            if a(i,j) >= b(i)
                sol.contribution(i,j) = true;
                if a(i,j) == 0
                    sol.help(i,j) = 1;
                else
                    sol.help(i,j) = b(i)/a(i,j);
                end
            end
        end
    end
    
    %Find greatest solution
    for j = 1:sol.cols
        %Takes the minimal element, bigger than 0, for the j-th column of A.
        col_min = min(sol.help(sol.contribution(:,j), j));

        if ~isempty(col_min)
            %All elemnts bigger than x_gr(j) should be even to 0.
            mask = sol.contribution(:,j) & (sol.help(:,j) > col_min);
            sol.contribution(mask, j) = false;
            sol.help(mask, j) = 0;

            sol.help(sol.contribution(:,j) & (a(:,j)==0), j) = 0;

            sol.gr(j) = col_min;
        end
        
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
                Pi  = find(sol.contribution(i,:)  == true);
                Pii = find(sol.contribution(ii,:) == true);
                if all(ismember(Pii, Pi)) && all(sol.help(ii, Pii) <= sol.help(i, Pii))
                    sol.dominated = [i sol.dominated];
                    break;
                elseif all(ismember(Pi, Pii)) && all(sol.help(i, Pi) <= sol.help(ii, Pi))
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
    obtain_low(1,zeros(sol.cols,1),marked);
    
    function obtain_low(i, low, marked)
        for jj = find(sol.contribution(i,:))
            nlow = low;
            nlow(jj) = sol.help(i,jj);
        
            nmarked = marked;
            nmarked(sol.contribution(:,jj)) = 1;
        
            nonmarked = find(nmarked==0);
            if isempty(nonmarked)
                add_low(nlow);
            else
                obtain_low(nonmarked(1),nlow,nmarked);
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