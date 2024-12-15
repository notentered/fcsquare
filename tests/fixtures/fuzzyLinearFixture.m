% Fixture with small examples for linear combinations / independence.

classdef fuzzyLinearFixture < matlab.unittest.fixtures.Fixture
    properties
        % Each example is a struct with fields:
        %   a          – fuzzyMatrix with columns as candidate vectors
        %   type       – composition string
        %   full       – logical flag for is_linindep
        %   dependent  – expected dependent column indices (for full=true)
        %   independent – expected boolean for full=false
        Examples
    end

    methods
        function setup(fixture)
            % Example 1: simple independence in maxmin
            A1 = fuzzyMatrix([0.2 0.5; 0.7 0.1]);
            fixture.Examples{1} = struct( ...
                'a', A1, ...
                'type', 'maxmin', ...
                'full', false, ...
                'independent', true, ...
                'dependent', [] ...  % unused when full=false
            );

            % Example 2: one column is fuzzy lin. comb. of others
            % (artificial example; adjust if needed after regeneration)
            A2 = fuzzyMatrix([0.2 0.4 0.4; 0.5 0.3 0.5]);
            fixture.Examples{2} = struct( ...
                'a', A2, ...
                'type', 'maxmin', ...
                'full', true, ...
                'independent', [], ...
                'dependent', [3] ... % third column dependent
            );
        end
    end
end
