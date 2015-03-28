%FUZZYOPTIMIZATIONPROBLEM Maximize or minimize fuzzy optimization problems.
%   OBJ = FUZZYOPTIMIZATIONPROBLEM(OBJECT,CONSTRAINTS) Created a
%   FUZZYOPTIMIZATIONPROBLEM object and specify its object function and a
%   fuzzy system as a system of constraints.
%
%   OBJ = FUZZYOPTIMIZATIONPROBLEM(OBJECT,CONSTRAINTS, SOLVE_CONSTRAINTS)
%   Created a FUZZYOPTIMIZATIONPROBLEM object, specify its object function,
%   a fuzzy system as a system of constraints and tells if the system of
%   constraints should be also solved or it is provided already solved.
%   SOLVE_CONSTRAINTS is a boolean property. Default is TRUE and its means
%   that the system of constraints should be also solved.
%   
%   Methods
%   -------
%   Type "methods fuzzyOptimizationProblem" to see a list of the methods.
%   This class extends class handle, so its methods will display as well.
%   Specific methods for this class are:
%   minimize, maximize
%
%   For more information about a particular method, type
%   "help fuzzyOptimizationProblem/methodname" at the command line.
%
%   Example 1
%   ---------
%   Create a fuzzy optimization problem with objective function:
%   
%   z = 3.x1 + 5.x2 + 7.x3
%   and maxmin fuzzy system of constraints with random matrix A and matrix B.
%   
%   z = [3 5 7];
%   a = fuzzyMatrix(rand(3)); b = fuzzyMatrix(rand(3,1));
%   s = fuzzySystem('maxmin', a, b);
%   o = fuzzyOptimizationProblem(z, s);
%   
%   References
%   ----------
%   1. K. Peeva, Zl. Zahariev, Optimization of linear cost function with
%   fuzzy max-product relational equation constraints, Proceedings of 32th
%   International Conference AMÅE, Sozopol June 2006, M. Marinov,
%   M. Todorov (eds), Softtrade, Sofia, 2007, ISBN 978-954-334-050-7,
%   pp 261-272.
%
%   2. K. Peeva, Zl, Zahariev, Iv. Atanasov, Optimization of Linear
%   Objective Function Under Max-product Fuzzy Relational Constraint,
%   Proceedings of the 9th WSEAS International Conference on FUZZY SYSTEMS
%   (FS’08) – Advanced Topics on Fuzzy Systems, Book Series: Artificial
%   Intelligence Series- WSEAS, Sofia, Bulgaria, May 2-4, 2008, ISBN:
%   978-960-6766-56-5, ISSN: 1790-5109, 132-137.
%   
%   3. K. Peeva, Zl. Zahariev, I. Atanasov, Software for optimization of
%   linear objective function with fuzzy relational constraint, Fourth
%   International IEEE Conference on Intelligent Systems, Sept. 2008,
%   Varna, Vol. 3 (2008), pp. 18-14–18-19, ISBN 978-I-4244-1739.
%   
%   4. Z. Zahariev, Software package and API in MATLAB for working with
%   fuzzy algebras, In International Conference „Applications of Mathematics
%   in Engineering and Economics (AMEE'09)”, AIP Conference Proceedings,
%   vol. 1184, G. Venkov, R. Kovatcheva, V. Pasheva (eds.) American
%   Institute of Physics, ISBN 978-0-7354-0750-9, 2009, 434-350.
classdef fuzzyOptimizationProblem < handle
    properties
        object          = [];
        constraints     = fuzzySystem();
        object_solution = [];
        object_value    = [];
%        solutions_gr    = [];
%        solutions_low   = [];
    end
    
    methods
        function obj = fuzzyOptimizationProblem(object,constraints,solve_constraints)
            %Constructor for fuzzyOptimizationProblem
            if nargin < 2
                error('Objective function parameters and the system of constraints should be provided to the constructor.');
            else
                if (nargin < 3) || (solve_constraints ~= false)
                    solve_constraints = true;
                end
                if nargin >= 2
                    obj.object = object;
                    obj.constraints = constraints;
                    obj.object_solution = zeros(1, length(obj.object));
                    if solve_constraints
                        obj.constraints.full = true;
                        obj.constraints.solve_inverse();
                    end
                end
            end
        end
        function obj = minimize(obj)
            %Minimize the objective function for a fuzzyOptimizationProblem
            %according provided fuzzy system of constraints
            obj.object_solution = zeros(1, length(obj.object));
            obj.object_value = [];
            object_length = length(obj.object);
            current_solution=zeros(1,object_length);
            
            for i = 1:size(obj.constraints.x.gr,2)
                current_solution(obj.object < 0) = obj.constraints.x.gr(obj.object < 0, i);
                for j = 1:size(obj.constraints.x.low,2)
                    current_solution(obj.object > 0) = obj.constraints.x.low(obj.object > 0, j);
                    
                    current_value=obj.object*current_solution';
                    
                    if (isempty(obj.object_value)) || (current_value < obj.object_value)
                        obj.object_value=current_value;
                        obj.object_solution=current_solution';
                    elseif current_value == obj.object_value
                        obj.object_solution = [obj.object_solution current_solution'];
                    end
                end
            end
        end
        function obj = maximize(obj)
            %Maximize the objective function for a fuzzyOptimizationProblem
            %according provided fuzzy system of constraints
            obj.object_solution = zeros(1, length(obj.object));
            obj.object_value = [];
            object_length = length(obj.object);
            current_solution=zeros(1,object_length);
            
            for i = 1:size(obj.constraints.x.gr,2)
                current_solution(obj.object > 0) = obj.constraints.x.gr(obj.object > 0, i);
                for j = 1:size(obj.constraints.low,2)
                    current_solution(obj.object < 0) = obj.constraints.x.low(obj.object < 0, j);
                    
                    current_value=obj.object*current_solution';
                    
                    if (isempty(obj.object_value)) || (current_value > obj.object_value)
                        obj.object_value=current_value;
                        obj.object_solution=current_solution';
                    elseif current_value == obj.object_value
                        obj.object_solution = [obj.object_solution current_solution'];
                    end
                end
            end
        end
    end
    
end

