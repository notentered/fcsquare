%FUZZYMACHINE Creates and finds behavior matrix for fuzzy machines.
%Minimize or reduce the result.
%   OBJ = FUZZYMACHINE() Construct a fuzzy machine.
%
%   OBJ = FUZZYMACHINE(INITIAL_SET) Created a FUZZYMACHNE object. The
%   initial set is a cell of fuzzy matrices with the transition matrices
%   for words with length 1.
%
%   OBJ = FUZZYMATRIX(INITIAL_SET,COMPOSITION) Created a FUZZYMACHNE object
%   and specify used composition. Default is 'maxmin'.
%
%   OBJ = FUZZYMATRIX(INITIAL_SET,COMPOSITION, POSTPROCESS) Created a
%   FUZZYMACHNE object, specify used composition and the postprocess
%   option. Can be 'reduce', 'minimize' or 'none'. Default is 'minimize'.
%   
%   OBJ = FUZZYMATRIX(INITIAL_SET,COMPOSITION, POSTPROCESS, WORD_LENGHT)
%   Created a FUZZYMACHNE object, specify used composition, the postprocess
%   option and the maximal word length. Can be any integer >= -1. -1 means
%   'unlimited'.
%   
%   OBJ = FUZZYMATRIX(INITIAL_SET,COMPOSITION, POSTPROCESS, WORD_LENGHT, FULL)
%   Created a FUZZYMACHNE object, specify used composition, the postprocess
%   option, the maximal word length and if the result behavior matrix
%   should be full behavior or not. Full is boolean, default is FALSE. If
%   set to TRUE, WORD_LENGTH should have value >= 0.
%   
%   Methods
%   -------
%   Type "methods fuzzyMachine" to see a list of the methods. This class
%   extends class handle, so its methods will display as well. Specific
%   method for this class is find_behavior.
%
%   For more information about a particular method, type
%   "help fuzzyMatrix/methodname" at the command line.
%
%   Example 1
%   ---------
%   Create a fuzzy machine with two input and two output letters, 'maxmin'
%   composition and 'minimize' for postprocess and find its behavior
%   matrix.
%
%   a = fuzzyMatrix(rand(2)); b = fuzzyMatrix(rand(2));
%   m = fuzzyMachine({a,b});
%   m.find_behavior();
%   
%   References
%   ----------
%   1. K. Peeva, Zl. Zahariev, Computing behavior of finite fuzzy machines
%   – Algorithm and its application to reduction and minimization,
%   Information Sciences, Vol. 178 (2008) issue 21, 4152-4165.
%   
%   2. Z. Zahariev, Software package and API in MATLAB for working with
%   fuzzy algebras, In International Conference „Applications of Mathematics
%   in Engineering and Economics (AMEE'09)”, AIP Conference Proceedings,
%   vol. 1184, G. Venkov, R. Kovatcheva, V. Pasheva (eds.) American
%   Institute of Physics, ISBN 978-0-7354-0750-9, 2009, 434-350.
classdef fuzzyMachine < handle
    properties
        initial_set = {};
        composition = 'maxmin';
        norm = 'max';
        conorm = 'min';
        postprocess = 'minimize';
        word_length = -1;
        full = false;
        behavior_matrix = [];
        letters = 0;
    end
    
    methods
        function obj = fuzzyMachine(initial_set,composition,postprocess,word_length,full)
            %Constructor for fuzzyMachine
            if nargin == 0
                error('Initial set of matrices for word length = 1 should be provided');
            end
            if nargin >= 1
                obj.initial_set = initial_set;
            end
            if nargin >= 2
                obj.composition = composition;
                obj.norm = obj.composition(1:3);
                obj.conorm = obj.composition(4:end);
            end
            if nargin >= 3
                if strcmp(postprocess,'reduce') || strcmp(postprocess, 'minimize')
                    obj.postprocess = postprocess;
                else
                    error('Postprocess can be either "reduce" or "minimize"');
                end
            end
            if (nargin >= 4) && isinteger(word_length) && (word_length >= 0)
                obj.word_length = word_length;
            end
            if (nargin >= 5) && (full == true)
                obj.full = true;
            end
            
            if (obj.full == true) && (word_length == -1)
                error ('For full bihevior matrix word length should be specified!');
            end
            
            obj.letters = length(initial_set{1});
            for i = 1:numel(initial_set)
                if (any(size(initial_set{i})~=[obj.letters obj.letters]))
                    error('All state matrices must be square matrices with the same size!');
                end
            end
        end
        
        function find_behavior(obj)
            %Finds the behavior matrix according the object properties and
            %saves it to the BEHAVIOR_MATRIX property.
            if (obj.full == true) && (obj.word_length < 0)
                error('Full behavior matrix cannot be obtained for words with arbitrary length. Plase, change either full to false or word_length to some number.');
            end
            switch obj.norm
                case 'max'
                    obj.behavior_matrix = ones(obj.letters,1);
                case 'min'
                    obj.behavior_matrix = zeros(obj.letters,1);
                otherwise
                    error(['Unsopported norm ' obj.norm '!']);
            end
            
            if obj.word_length == 0
                return;
            end
            
            for i = 1:length(obj.initial_set)
                col = fuzzyMatrix(feval(obj.norm,obj.initial_set{i},[],2));
                if obj.full == true || ~any(is_lincomb(obj.composition,obj.behavior_matrix, col))
                    obj.behavior_matrix(:,size(obj.behavior_matrix,2)+1) = col;
                end
            end
            
            start = 2;
            word_length = 2;
            new_start = size(obj.behavior_matrix,2) + 1;
            initial_set_length = length(obj.initial_set);
            
            while (obj.word_length == -1) || (word_length <= obj.word_length)
                current_size = size(obj.behavior_matrix,2);
                for i = 1:initial_set_length
                    for j = start:current_size
                        col = fuzzyMatrix(feval(obj.composition,obj.initial_set{i}, obj.behavior_matrix(:,j)));
                        if obj.full == true || ~any(is_lincomb(obj.composition,obj.behavior_matrix, col))
                            obj.behavior_matrix(:,size(obj.behavior_matrix,2)+1) = col;
                        end
                    end
                end
                
                if start == size(obj.behavior_matrix,2) + 1
                    break;
                end
                
                start = new_start;
                new_start = size(obj.behavior_matrix,2) + 1;
                word_length = word_length + 1;
            end
            
            obj.behavior_matrix = fuzzyMatrix(obj.behavior_matrix);
            switch obj.postprocess
                case 'reduce'
                    obj.behavior_matrix = obj.behavior_matrix';
                    for i = size(obj.behavior_matrix,2):-1:1
                        for j = i-1:-1:1
                            if (all(obj.behavior_matrix(:,i) == obj.behavior_matrix(:,j)))
                                obj.behavior_matrix(:, i) = [];
                            end
                        end
                    end
                    obj.behavior_matrix = obj.behavior_matrix';
                case 'minimize'
                    obj.behavior_matrix = obj.behavior_matrix';
                    for i = size(obj.behavior_matrix,2):-1:1
                        if any(is_lincomb(obj.composition, obj.behavior_matrix, i))
                            obj.behavior_matrix(:,i) = [];
                        end
                    end
                    obj.behavior_matrix = obj.behavior_matrix';
            end
        end
    end
end

