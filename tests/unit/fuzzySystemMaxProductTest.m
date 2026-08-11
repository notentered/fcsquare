classdef fuzzySystemMaxProductTest < matlab.unittest.TestCase
    % Deterministic and exhaustive-oracle tests for max-product systems.

    properties (Constant)
        DevelopmentRepetitions = 10
    end

    methods (Test)
        function testPublishedEquationAndInequalityExamples(testCase)
            fixture = testCase.applyFixture(fuzzySystemLiteratureFixture);
            ex = fixture.MaxProduct;

            for inequalities = [-1 0 1]
                system = fuzzySystem('maxprod', ex.a, ex.b, [], true, inequalities);
                system.solve_inverse();

                testCase.verifyTrue(system.x.exist, ex.source);
                if inequalities == -1
                    expectedLow = zeros(6, 1);
                    expectedGr = ex.greatest;
                elseif inequalities == 0
                    expectedLow = ex.minimal;
                    expectedGr = ex.greatest;
                else
                    expectedLow = ex.minimalGreaterOrEqual;
                    expectedGr = ones(6, 1);
                end
                testCase.verifyEqual(canonical(system.x.low), ...
                    canonical(expectedLow), 'AbsTol', 1e-12, ex.source);
                testCase.verifyEqual(canonical(system.x.gr), ...
                    canonical(expectedGr), 'AbsTol', 1e-12, ex.source);
            end
        end

        function testZeroCoefficientBoundaryAndInconsistency(testCase)
            zeroBoundary = fuzzySystem('maxprod', ...
                fuzzyMatrix([0 0.5]), fuzzyMatrix(0), [], true);
            zeroBoundary.solve_inverse();
            testCase.verifyTrue(zeroBoundary.x.exist);
            testCase.verifyEqual(double(zeroBoundary.x.gr), [1; 0]);
            testCase.verifyEqual(double(zeroBoundary.x.low), [0; 0]);

            inconsistent = fuzzySystem('maxprod', ...
                fuzzyMatrix([0 0.2]), fuzzyMatrix(0.3), [], true);
            inconsistent.solve_inverse();
            testCase.verifyFalse(inconsistent.x.exist);
            testCase.verifyEqual(inconsistent.x.contradict(:).', 1);
        end

        function testEquationAndInequalitiesAgainstIndependentOracle(testCase)
            for repetition = 1:testCase.DevelopmentRepetitions
                rng(6100 + repetition, 'twister');
                a = fuzzyMatrix(randi([0 4], 2, 3) / 4);
                witness = fuzzyMatrix(randi([0 4], 3, 1) / 4);
                b = maxprod(a, witness);

                for inequalities = [-1 0 1]
                    expected = referenceMaxProductSolutions(a, b, inequalities);
                    actual = fuzzySystem('maxprod', a, b, [], true, inequalities);
                    actual.solve_inverse();

                    context = sprintf(['max-product oracle mismatch\n' ...
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
