% Fixture for fuzzyOptimizationProblem tests.

classdef fuzzyOptimizationFixture < matlab.unittest.fixtures.Fixture
    properties
        Examples
    end

    methods
        function setup(fixture)
            % Example 1: minimize with simple 2-variable system
            A = fuzzyMatrix([0.8 0.3; 0.2 0.7]);
            X = fuzzyMatrix([0.5; 0.9]);
            B = maxprod(A, X);  % example constraints

            sys = fuzzySystem('maxprod', A, B);
            sys.full = true;
            sys.solve_inverse();

            z = [3 5]; % objective coefficients

            fixture.Examples{1} = struct( ...
                'object', z, ...
                'constraints', sys, ...
                'operation', 'minimize', ...
                'expectedSign', 'min' ... % just to distinguish
            );

            % Example 2: maximize with same system
            fixture.Examples{2} = struct( ...
                'object', z, ...
                'constraints', sys, ...
                'operation', 'maximize', ...
                'expectedSign', 'max' ...
            );
        end
    end
end
