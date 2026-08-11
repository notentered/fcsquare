classdef fuzzySystemGoguenTest < matlab.unittest.TestCase
    % Published and exhaustive-oracle tests for min-Goguen systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testPublishedEquationExample(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.Goguen;
            system = fuzzySystem('goguen', ex.a, ex.b, [], true);

            system.solve_inverse();

            testCase.verifyTrue(system.x.exist, ex.source);
            testCase.verifyEqual(double(system.x.low), double(ex.least), ...
                'AbsTol', 1e-12, ex.source);
            testCase.verifyEqual(canonical(system.x.gr), canonical(ex.maximal), ...
                'AbsTol', 1e-12, ex.source);
        end

        function testZeroCoefficientAndInconsistentSystem(testCase)
            zeroCoefficient = fuzzySystem('goguen', ...
                fuzzyMatrix([0 0.8]), fuzzyMatrix(0.5), [], true);
            zeroCoefficient.solve_inverse();
            testCase.verifyTrue(zeroCoefficient.x.exist);
            testCase.verifyEqual(double(zeroCoefficient.x.low), [0; 0.4]);
            testCase.verifyEqual(double(zeroCoefficient.x.gr), [1; 0.4]);

            inconsistent = fuzzySystem('goguen', ...
                fuzzyMatrix([0 0]), fuzzyMatrix(0.5), [], true);
            inconsistent.solve_inverse();
            testCase.verifyFalse(inconsistent.x.exist);
            testCase.verifyEqual(inconsistent.x.contradict(:).', 1);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(7200 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = goguen(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceGoguenSolutions(a, b, inequalities);
                    actual = fuzzySystem('goguen', a, b, [], true, inequalities);

                    context = sprintf(['min-Goguen oracle mismatch\n' ...
                        'repetition=%d, inequalities=%d\nA=%s\nB=%s'], ...
                        repetition, inequalities, mat2str(double(a)), ...
                        mat2str(double(b)));
                    verifyNoException(testCase, @() actual.solve_inverse(), context);
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
