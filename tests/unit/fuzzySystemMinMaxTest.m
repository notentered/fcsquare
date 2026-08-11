classdef fuzzySystemMinMaxTest < matlab.unittest.TestCase
    % Deterministic and exhaustive-oracle tests for min-max systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testPublishedEquationExample(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.MinMax;
            testCase.verifyEqual(double(minmax(ex.a, ex.witness)), ...
                double(ex.b), 'AbsTol', 1e-12, ex.source);

            system = fuzzySystem('minmax', ex.a, ex.b, [], true);
            system.solve_inverse();

            testCase.verifyTrue(system.x.exist, ex.source);
            testCase.verifyEqual(double(system.x.low), double(ex.least), ...
                'AbsTol', 1e-12, ex.source);
            testCase.verifyEqual(canonical(system.x.gr), canonical(ex.maximal), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testBoundaryAndInconsistentSystems(testCase)
            oneSystem = fuzzySystem('minmax', ...
                fuzzyMatrix([0.4 1.0; 1.0 0.6]), fuzzyMatrix([1; 1]), [], true);
            oneSystem.solve_inverse();
            testCase.verifyTrue(oneSystem.x.exist);
            testCase.verifyEqual(double(oneSystem.x.low), [1; 1]);
            testCase.verifyEqual(double(oneSystem.x.gr), [1; 1]);

            inconsistent = fuzzySystem('minmax', ...
                fuzzyMatrix([1 1]), fuzzyMatrix(0.9), [], true);
            inconsistent.solve_inverse();
            testCase.verifyFalse(inconsistent.x.exist);
            testCase.verifyEqual(inconsistent.x.contradict(:).', 1);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(5100 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = minmax(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceMinMaxSolutions(a, b, inequalities);
                    actual = fuzzySystem('minmax', a, b, [], true, inequalities);
                    actual.solve_inverse();

                    context = sprintf(['min-max oracle mismatch\n' ...
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
