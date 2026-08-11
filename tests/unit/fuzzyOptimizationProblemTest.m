classdef fuzzyOptimizationProblemTest < matlab.unittest.TestCase

    methods (Test)
        function testConstructorSolvesConstraintsByDefault(testCase)
            % Build a simple system that is not solved yet
            A = fuzzyMatrix(rand(2));
            X = fuzzyMatrix(rand(2,1));
            B = maxmin(A, X);
            s = fuzzySystem('maxmin', A, B);

            % Constructor should solve constraints when solve_constraints
            % is omitted (default true)
            o = fuzzyOptimizationProblem([1 1], s);

            testCase.verifyTrue(o.constraints.full, ...
                'Constructor should set constraints.full = true when solving constraints.');
            testCase.verifyTrue(isfield(o.constraints.x, 'exist') && o.constraints.x.exist, ...
                'Constraints should be solved and have a solution.');
        end

        function testConstructorDoesNotSolveWhenFlagFalse(testCase)
            A = fuzzyMatrix(rand(2));
            X = fuzzyMatrix(rand(2,1));
            B = maxmin(A, X);
            s = fuzzySystem('maxmin', A, B);

            o = fuzzyOptimizationProblem([1 1], s, false);

            % x should still be empty or not have exist field
            hasX = isprop(o.constraints, 'x') || isfield(o.constraints, 'x');
            checkExist = false;
            if hasX && isstruct(o.constraints.x)
                checkExist = isfield(o.constraints.x, 'exist');
            end

            testCase.verifyFalse(checkExist, ...
                'Constraints should not be solved when solve_constraints=false.');
        end

        function testMinimizeAndMaximizeExamples(testCase)
            fixture = testCase.applyFixture(fuzzyOptimizationFixture);

            for k = 1:numel(fixture.Examples)
                ex = fixture.Examples{k};

                % Note: constraints in fixture are already solved.
                o = fuzzyOptimizationProblem(ex.object, ex.constraints, false);

                % Call minimize or maximize dynamically
                o.(ex.operation)();

                testCase.verifyNotEmpty(o.object_solution, ...
                    sprintf('object_solution should not be empty after %s.', ex.operation));
                testCase.verifyNotEmpty(o.object_value, ...
                    sprintf('object_value should not be empty after %s.', ex.operation));
                testCase.verifyEqual(double(o.object_solution), ...
                    double(ex.expected_solution), 'AbsTol', 1e-12, ...
                    sprintf('Incorrect optimizer for published %s example.', ex.operation));
                testCase.verifyEqual(o.object_value, ex.expected_value, ...
                    'AbsTol', 1e-12, ...
                    sprintf('Incorrect objective value for published %s example.', ex.operation));
            end
        end
    end
end
