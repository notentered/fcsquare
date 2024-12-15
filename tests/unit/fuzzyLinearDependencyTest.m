% Tests for is_linindep and the behavior of full vs non-full mode.

classdef fuzzyLinearDependencyTest < matlab.unittest.TestCase

    methods (Test)
        function testIsLinIndepBoolean(testCase)
            fixture = testCase.applyFixture(fuzzyLinearFixture);
            ex = fixture.Examples{1};

            result = is_linindep(ex.a, ex.type); % default full=false
            testCase.verifyTrue(result, ...
                'Expected columns to be fuzzy linearly independent in boolean mode.');
        end

        function testIsLinIndepDependentIndices(testCase)
            fixture = testCase.applyFixture(fuzzyLinearFixture);
            ex = fixture.Examples{2};

            depIdx = is_linindep(ex.a, ex.type, true); % full=true

            % We only care that the expected dependent indices are contained
            testCase.verifyEqual(sort(depIdx(:).'), sort(ex.dependent(:).'), ...
                'Dependent indices did not match expected ones.');
        end
    end
end
