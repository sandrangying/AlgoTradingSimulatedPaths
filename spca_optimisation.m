function simObj = spca_optimisation(simObj, lambda)
% Risk aversion optimisation using sparse PCs
% Using https://www.jstatsoft.org/article/view/v084i10 for sparse PCA
    if nargin < 2
        lambda = 0.5;
    end
    simObj.reset(); % reset simulation environment
    options = optimset('Display','Off');
    warmup = 100;
    k=2; % no. of sparse PCs
    stop = floor(0.5 * simObj.d + (lambda/20)*0.25*simObj.d); % no. of non-zero variables in PC 
    % key is to find optimal way to set stop as a function of lambda
    
    for i = 1:simObj.T
        if i < warmup
            w_const = ones(simObj.d,1)/simObj.d;
        else
            rets = diff(log(simObj.s_hist(:,1:i)),1,2);
            B = spca(rets',[],k, inf, -stop); % sparse loading vectors
            pcs = B' * rets; 
            errors = rets - B * pcs;
            Omega = diag(mean(errors.^2, 2)); 
            estim_cov = B * (pcs * pcs') * B' + Omega;
            mean_rets = mean(rets, 2)';
            % H (cov), f (expected returns), A , b (Ax < b),
            % Aeq, beq (Aeq x = beq), m lb, ub (lb < x < ub), x0
            % the optimisation problem is
            % argmin_{w} 0.5 w^{T}Hw + f w , Aw = b
            % so f = -1E[R] / 2lambda
            w_const = quadprog(estim_cov, -1/(2 * lambda) * mean_rets, [],[],...
                ones(1, simObj.d), 1,...
                zeros(1, simObj.d), ones(1, simObj.d),...
                w_const, options);
        end
        simObj.step(w_const);
    end
end