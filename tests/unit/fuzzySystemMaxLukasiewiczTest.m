classdef fuzzySystemMaxLukasiewiczTest < matlab.unittest.TestCase
    % Published and exhaustive-oracle tests for max-Lukasiewicz systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testPublishedEquationExample(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.MaxLukasiewicz;
            system = fuzzySystem( ...
                'maxlukasiewicz', ex.a, ex.b, [], true);

            system.solve_inverse();

            testCase.verifyTrue(system.x.exist, ex.source);
            testCase.verifyEqual(double(system.x.gr), double(ex.greatest), ...
                'AbsTol', 1e-12, ex.source);
            testCase.verifyEqual(canonical(system.x.low), canonical(ex.minimal), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testZeroBoundaryAndInconsistentSystem(testCase)
            zeroBoundary = fuzzySystem('maxlukasiewicz', ...
                fuzzyMatrix([0.4 0.8]), fuzzyMatrix(0), [], true);
            zeroBoundary.solve_inverse();
            testCase.verifyTrue(zeroBoundary.x.exist);
            testCase.verifyEqual(double(zeroBoundary.x.low), [0; 0]);
            testCase.verifyEqual(double(zeroBoundary.x.gr), [0.6; 0.2], ...
                'AbsTol', 1e-12);

            inconsistent = fuzzySystem('maxlukasiewicz', ...
                fuzzyMatrix([0.2 0.4]), fuzzyMatrix(0.8), [], true);
            inconsistent.solve_inverse();
            testCase.verifyFalse(inconsistent.x.exist);
            testCase.verifyEqual(inconsistent.x.contradict(:).', 1);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(7500 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = maxlukasiewicz(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceMaxLukasiewiczSolutions( ...
                        a, b, inequalities);
                    actual = fuzzySystem( ...
                        'maxlukasiewicz', a, b, [], true, inequalities);

                    context = sprintf(['max-Lukasiewicz oracle mismatch\n' ...
                        'repetition=%d, inequalities=%d\nA=%s\nB=%s'], ...
                        repetition, inequalities, mat2str(double(a)), ...
                        mat2str(double(b)));
                    verifyNoException(testCase, @() actual.solve_inverse(), context);
                    testCase.verifyEqual(actual.x.exist, expected.exist, context);
                    if expected.exist
                        testCase.verifyEqual(canonical(actual.x.gr), ...
                            canonical(expected.gr), 'AbsTol', 1e-12, context);
                        testCase.verifyEqual(canonical(actual.x.low), ...
                            canonical(expected.low), 'AbsTol', 1e-12, context);
                    end
                end
            end
        end
    end
end

function result = canonical(solutions)
    result = sortrows(double(solutions).').';
end
