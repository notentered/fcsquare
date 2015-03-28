%FUZZYSYSTEM Define and solve fuzzy linear system of equations or
%inequalities.
%   OBJ = FUZZYSYSTEM() Create a an empty FUZZYSYSTEM object. 
%
%   OBJ = FUZZYSYSTEM(COMPOSITION) Created a FUZZYSYSTEM object and specify
%   its composition.
%   
%   OBJ = FUZZYSYSTEM(COMPOSITION, A) Created a FUZZYSYSTEM object, specify
%   its composition and a fuzzy matrix as a matrix of the coefficients.
%   
%   OBJ = FUZZYSYSTEM(COMPOSITION, A, B) Created a FUZZYSYSTEM object, specify
%   its composition, a fuzzy matrix as a matrix of the coefficients and the
%   right-hand side fuzzy vector of the system.
%   
%   OBJ = FUZZYSYSTEM(COMPOSITION, A, B, X) Created a FUZZYSYSTEM object, specify
%   its composition, a fuzzy matrix as a matrix of the coefficients, the
%   right-hand side fuzzy vector of the system and the vector with the
%   unknowns.
%   
%   OBJ = FUZZYSYSTEM(COMPOSITION, A, B, X, FULL) Created a FUZZYSYSTEM
%   object, specify its composition, a fuzzy matrix as a matrix of the
%   coefficients, the right-hand side fuzzy vector of the system, the
%   vector with the unknowns and whether full solution should be obtained
%   on solving the system. If TRUE, on solving the system, property X will
%   contain a structure all the solutions of the system. If FALSE, only
%   the greatest/lower (depends on the system's norm) solution will be
%   given. Default is FALSE.
%   
%   OBJ = FUZZYSYSTEM(COMPOSITION, A, B, X, FULL, INEQUALITIES) Created a
%   FUZZYSYSTEM object, specify its composition, a fuzzy matrix as a matrix
%   of the coefficients, the right-hand side fuzzy vector of the system, the
%   vector with the unknowns, whether full solution should be obtained
%   on solving the system and whether the system is with equations or with
%   inequalities. INEQUALITIES can hold one of -1, 0, +1. If -1 then the
%   system is A.X <= B, if +1 the system is A.X>=B, if 0 the system is
%   A.X=B. Deafault is 0.
%   
%   Methods
%   -------
%   Type "methods fuzzySystem" to see a list of the methods. This class
%   extends class handle, so its methods will display as well. Specific
%   methods for this class are:
%   solve_direct, solve_inverse
%
%   For more information about a particular method, type
%   "help fuzzySystem/methodname" at the command line.
%
%   Example 1
%   ---------
%   Create random fuzzy system of '<=' inequalities with max-product
%   composition and solve its inverse problem, finding all its solutions:
%   
%   a = fuzzyMatrix(5); b = fuzzyMatrix(5,1);
%   s = fuzzySystem('maxprod', a, b, fuzzyArray(), true, -1);
%   
%   References
%   ----------
%   1. Z. Zahariev, “Solving Max-min Relational Equations. Software and
%   Applications”, in International conference on Applications of
%   Mathematics in Engineering and Economics, June 2008, Sozopol, Bulgaria,
%   December 2008, pp 516-523.%   
%   2. Z. Zahariev, Software package and API in MATLAB for working with
%   fuzzy algebras, In International Conference „Applications of Mathematics
%   in Engineering and Economics (AMEE'09)”, AIP Conference Proceedings,
%   vol. 1184, G. Venkov, R. Kovatcheva, V. Pasheva (eds.) American
%   Institute of Physics, ISBN 978-0-7354-0750-9, 2009, 434-350.
classdef fuzzySystem < handle
    properties
        composition  = '';
        a            = fuzzyMatrix();
        b            = fuzzyMatrix();
        x            = fuzzyMatrix();
        full         = false;
        inequalities = 0;
    end
    
    methods
        function obj = fuzzySystem(composition,a,b,x,full,inequalities)
            if nargin >= 1
                obj.composition = composition;
            end
            if nargin >= 2
                obj.a = fuzzyMatrix(a);
            end
            if nargin >=3
                obj.b = fuzzyMatrix(b);
            end
            if nargin >=4
                obj.x = fuzzyMatrix(x);
            end
            if (nargin >=5) && (full == true)
                obj.full = true;
            end
            if (nargin >=6) && ismember(inequalities, [-1 1])
                obj.inequalities = inequalities;
            end
        end
        
        function obj = solve_direct(obj)
            %Calculate the direct problem resolution (A.X = ?) for a fuzzy
            %linear system os equations/inequalities.
            if isempty(obj.x)
                error('Vector or scruct x must be provided in order to solve the direct problem.');
            else
                if obj.full == true
                    obj.b = feval(obj.composition, obj.a, obj.x.gr(:,1));
                else
                    obj.b = feval(obj.composition, obj.a, obj.x);
                end
            end
        end
        
        function obj = solve_inverse(obj)
            %Solve the inverse problem (A.? = B) for a fuzzy linear system
            %of equations/inequalities.
            if isempty(obj.b)
                error('Vector b must be provided in order to solve the inverse problem.');
            else
                obj.x = feval(['s' obj.composition], double(obj.a), double(obj.b), obj.inequalities, obj.full);
                
                if isstruct(obj.x)
                    if obj.full == true
                        obj.x.help = fuzzyMatrix(obj.x.help);
                        if obj.x.exist == true
                            obj.x.low  = fuzzyMatrix(obj.x.low);
                            obj.x.gr   = fuzzyMatrix(obj.x.gr);
                        end
                    else
                        obj.x = false;
                    end
                else
                    obj.x = fuzzyMatrix(obj.x);
                end
            end
        end
    end
end

