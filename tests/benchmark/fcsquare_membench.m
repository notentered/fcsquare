function R = fcsquare_membench(m, n)
    A = fuzzyMatrix(rand(m,n));
    X = fuzzyMatrix(rand(n,1));
    B = maxmin(A,X);

    profile clear; profile -memory on;
    fuzzySystem('maxmin', A, B, [], false).solve_inverse();
    p1 = profile('info'); profile off;
    [mem_g, field_g] = sum_profile_mem_bytes(p1);

    profile clear; profile -memory on;
    fuzzySystem('maxmin', A, B, [], true).solve_inverse();
    p2 = profile('info'); profile off;
    [mem_f, field_f] = sum_profile_mem_bytes(p2);

    R = struct();
    R.m = m; R.n = n;

    R.greatest.mem_bytes = mem_g;
    R.full.mem_bytes     = mem_f;

    R.greatest.mem_field = field_g;
    R.full.mem_field     = field_f;

    fprintf('\nSingle-run memory benchmark: m=%d, n=%d\n', m, n);
    fprintf('Greatest-only allocated mem (bytes): %.0f  (field=%s)\n', R.greatest.mem_bytes, R.greatest.mem_field);
    fprintf('Full-solution allocated mem (bytes): %.0f  (field=%s)\n', R.full.mem_bytes, R.full.mem_field);
end

function [bytes, fieldUsed] = sum_profile_mem_bytes(p)
    bytes = NaN;
    fieldUsed = "";
    ft = p.FunctionTable;

    candidates = {'TotalMemAllocated','AllocatedMemory','TotalAllocatedMemory','TotalMem','PeakMem'};
    for i = 1:numel(candidates)
        f = candidates{i};
        if isfield(ft, f)
            bytes = sum([ft.(f)]);
            fieldUsed = f;
            return;
        end
    end
end
