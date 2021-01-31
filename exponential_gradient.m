function simObj = exponential_gradient(simObj)
    % Define momentum score
    % https://hudsonthames.org/online-portfolio-selection-momentum/
    simObj = simObj.reset(); % reset simulation environment
    w_const = ones(simObj.d,1)/simObj.d; % equal weighted portfolio vector
    lr = 1/simObj.T;
    for i=1:simObj.T
        % multiplicative update
%         w_const = w_const .* exp(lr .* simObj.s_cur ./ dot(w_const, simObj.s_cur));
        % gradient projection
        w_const = w_const + lr .*...
                  ((simObj.s_cur ./ dot(w_const,simObj.s_cur))  - (mean(simObj.s_cur) ./ dot(w_const,simObj.s_cur)));
        % expectation maximisation
%         w_const = w_const .* (lr .* ((simObj.s_cur ./ dot(w_const, simObj.s_cur)) - 1) + 1);
        w_const = w_const .* (w_const > 0);
        w_const = w_const / sum(w_const);
        simObj = simObj.step(w_const);
    end
end