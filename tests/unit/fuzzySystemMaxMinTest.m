classdef fuzzySystemMaxMinTest < matlab.unittest.TestCase
    % Deterministic and exhaustive-oracle tests for max-min systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testPublishedEquationExample(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.MaxMin;
            system = fuzzySystem('maxmin', ex.a, ex.b, [], true);

            system.solve_inverse();

            testCase.verifyTrue(system.x.exist, ex.source);
            testCase.verifyEqual(double(system.x.gr), double(ex.greatest), ...
                'AbsTol', 1e-12, ex.source);
            testCase.verifyEqual(canonical(system.x.low), canonical(ex.minimal), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testBoundaryAndInconsistentSystems(testCase)
            zeroSystem = fuzzySystem('maxmin', ...
                fuzzyMatrix([0.4 0.0; 0.0 0.6]), fuzzyMatrix([0; 0]), [], true);
            zeroSystem.solve_inverse();
            testCase.verifyTrue(zeroSystem.x.exist);
            testCase.verifyEqual(double(zeroSystem.x.gr), [0; 0]);
            testCase.verifyEqual(double(zeroSystem.x.low), [0; 0]);

            inconsistent = fuzzySystem('maxmin', ...
                fuzzyMatrix([0.2 0.3; 0.0 0.0]), fuzzyMatrix([0.3; 0.1]), [], true);
            inconsistent.solve_inverse();
            testCase.verifyFalse(inconsistent.x.exist);
            testCase.verifyEqual(inconsistent.x.contradict(:).', 2);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(4100 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = maxmin(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceMaxMinSolutions(a, b, inequalities);
                    actual = fuzzySystem('maxmin', a, b, [], true, inequalities);
                    actual.solve_inverse();

                    context = sprintf(['max-min oracle mismatch\n' ...
                        'repetition=%d, inequalities=%d\nA=%s\nB=%s'], ...
                        repetition, inequalities, mat2str(double(a)), ...
                        mat2str(double(b)));
                    testCase.verifyEqual(actual.x.exist, expected.exist, context);
                    if expected.exist
                        testCase.verifyEqual(canonical(actual.x.low), ...
                            canonical(expected.low), 'AbsTol', 1e-12, context);
                        testCase.verifyEqual(canonical(actual.x.gr), ...
                            canonical(expected.gr), 'AbsTol', 1e-12, context);
                    end
                end
            end
        end
    end
end

function result = canonical(solutions)
    result = sortrows(double(solutions).').';
end
