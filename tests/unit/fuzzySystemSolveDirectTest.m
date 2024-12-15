% Tests for fuzzySystem.solve_direct using examples from
% fuzzyMatrixCompositionFixtures.

classdef fuzzySystemSolveDirectTest < matlab.unittest.TestCase

    methods (Test)
        function testSolveDirectBasicExample(testCase)
            % Use a literature example from fuzzyMatrixCompositionFixtures
            fixture = testCase.applyFixture(fuzzyMatrixCompositionFixtures);
            example = fixture.ExamplesMaxMin{1};

            % Direct problem: given A and x, compute b = A ∘ x
            s = fuzzySystem('maxmin', example.a);
            s.x = example.b;   % use the B from composition fixture as "x"
            s.full = false;

            s.solve_direct();

            testCase.verifyEqual(double(s.b), double(example.expected), ...
                'AbsTol', 1e-10, ...
                'Direct solution did not match expected composition result.');
        end

        function testSolveDirectRequiresX(testCase)
            % If x is empty, solve_direct must throw an error
            A = fuzzyMatrix(rand(2));
            s = fuzzySystem('maxmin', A);

            didError = false;
            try
                s.solve_direct();
            catch
                didError = true;
            end

            testCase.verifyTrue(didError, ...
                'solve_direct should error when x is not provided.');
        end

        function testSolveDirectFullUsesFirstGrColumn(testCase)
            % When full=true, x is a struct with field gr and first column
            % should be used for the direct problem.
            A = fuzzyMatrix(rand(3));
            xStruct.gr = fuzzyMatrix(rand(3, 2));  % two candidate solutions
            xStruct.low = fuzzyMatrix(rand(3, 2)); % not used here
            xStruct.exist = true;

            s = fuzzySystem('maxmin', A);
            s.x = xStruct;
            s.full = true;

            s.solve_direct();

            expected = maxmin(A, xStruct.gr(:,1));
            testCase.verifyEqual(double(s.b), double(expected), ...
                'AbsTol', 1e-10, ...
                'When full=true, solve_direct must use x.gr(:,1) as input.');
        end

        function testSolveDirectNonFullUsesXAsMatrix(testCase)
            % When full=false, x is a fuzzyMatrix and is used directly.
            A = fuzzyMatrix(rand(2));
            X = fuzzyMatrix(rand(2,1));

            s = fuzzySystem('maxmin', A);
            s.x = X;
            s.full = false;

            s.solve_direct();

            expected = maxmin(A, X);
            testCase.verifyEqual(double(s.b), double(expected), ...
                'AbsTol', 1e-10, ...
                'When full=false, solve_direct must use x directly as a matrix.');
        end
    end
end
