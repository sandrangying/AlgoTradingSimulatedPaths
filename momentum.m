function simObj = momentum(simObj)
    % Define momentum score
    % e.g. normalised return
    % Assign asset weight = momentum score / sum momentum score
    simObj = simObj.reset(); % reset simulation environment
    w_const = ones(simObj.d,1)/simObj.d; % equal weighted portfolio vector
    W = 5;
    freq = 1;
    for i=1:simObj.T
        if mod(i, freq) == 0 && i > W
            ma10 = mean(simObj.s_hist(:,(i - W + 1):i), 2);
            w_const = simObj.s_cur ./ ma10;
            w_const = w_const ./ sum(w_const);
            simObj = simObj.step(w_const);
        else
            simObj = simObj.step(w_const);
        end
    end
end