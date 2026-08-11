classdef fuzzyMachineTest < matlab.unittest.TestCase

    methods (Test)
        function testFuzzyMachineConstructorAndFindBehavior(testCase)
            fixture = testCase.applyFixture(fuzzyMachineFixture);
            ex = fixture.Examples{1};

            m = fuzzyMachine(ex.initial_set, ex.composition, ...
                             ex.postprocess, ex.word_length, ex.full);

            % letters should be consistent with initial_set
            testCase.verifyEqual(m.letters, ex.expected_letters, ...
                'Incorrect number of letters inferred from initial_set.');

            m.find_behavior();

            testCase.verifyEqual( ...
                double(m.behavior_matrix), double(ex.expected_behavior), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testFuzzyMachineRejectsNonSquareMatrices(testCase)
            A1 = fuzzyMatrix(rand(2,3));
            initial_set = {A1};
            testCase.verifyError(@() fuzzyMachine(initial_set, 'maxmin'), ...
                'fuzzyMachine:NonSquareTransitionMatrix', ...
                'Non-square matrices should be rejected by the constructor.');
        end
    end
end
