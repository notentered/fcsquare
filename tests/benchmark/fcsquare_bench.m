function R = fcsquare_bench(m, n, K)

    t_greatest = zeros(K,1);
    t_full     = zeros(K,1);
    n_low      = nan(K,1);   % number of lower solutions (full run)

    for k = 1:K
        A = fuzzyMatrix(rand(m,n));
        X = fuzzyMatrix(rand(n,1));
        B = maxmin(A,X);

        % -------- Greatest solution only (time) --------
        tic;
        fuzzySystem('maxmin', A, B, [], false).solve_inverse();
        t_greatest(k) = toc;

        % -------- Full solution (time + #lower solutions) --------
        tic;
        fs = fuzzySystem('maxmin', A, B, [], true);
        fs.solve_inverse();
        t_full(k) = toc;

        % Extract number of lower solutions
        try
            % Most common case: fs.x.low is n x S
            n_low(k) = size(fs.x.low, 2);
        catch
            try
                % Alternative layout (if applicable)
                n_low(k) = size(fs.sol.low, 2);
            catch
                % leave NaN if structure differs
            end
        end
    end

    % -------- Summary --------
    R = struct();
    R.m = m; R.n = n; R.K = K;

    R.t_greatest = t_greatest;
    R.t_full     = t_full;
    R.n_low      = n_low;

    R.greatest.time_total = sum(t_greatest);
    R.greatest.time_mean  = mean(t_greatest);
    R.greatest.time_min   = min(t_greatest);
    R.greatest.time_max   = max(t_greatest);

    R.full.time_total = sum(t_full);
    R.full.time_mean  = mean(t_full);
    R.full.time_min   = min(t_full);
    R.full.time_max   = max(t_full);

    % Align #solutions with fastest / slowest runs
    [~, i_fast] = min(t_full);
    [~, i_slow] = max(t_full);

    R.full.n_low_mean      = mean(n_low, 'omitnan');
    R.full.n_low_fastest   = n_low(i_fast);
    R.full.n_low_slowest   = n_low(i_slow);

    % -------- Print report --------
    fprintf('\nSingle-size experiment: m=%d, n=%d, K=%d\n', m, n, K);

    fprintf('\nGreatest solution only:\n');
    fprintf('Time (s): total=%.4f  mean=%.4f  min=%.4f  max=%.4f\n', ...
        R.greatest.time_total, R.greatest.time_mean, ...
        R.greatest.time_min, R.greatest.time_max);

    fprintf('\nFull solution (including enumeration):\n');
    fprintf('Time (s): total=%.4f  mean=%.4f  min=%.4f  max=%.4f\n', ...
        R.full.time_total, R.full.time_mean, ...
        R.full.time_min, R.full.time_max);

    fprintf('# solutions: mean=%.2f  fastest=%g  slowest=%g\n', ...
        R.full.n_low_mean, R.full.n_low_fastest, R.full.n_low_slowest);
end
