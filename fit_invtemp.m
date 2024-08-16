function [B, p, LL] = fit_invtemp(tbl,include_bias)

    % Fit inverse temperature for resource-rational policy
    %
    % USAGE: [B, p] = fit_invtemp(tbl,[include_bias])
    %
    % INPUTS:
    %   tbl - dataset
    %   include_bias - 1 = include (default), 0 = don't include
    %
    % OUTPUTS:
    %   B - inverse temperatures
    %   p - choice probabilities
    %   LL - maximized log likelihoods

    if nargin < 2; include_bias = 1; end

    b = linspace(0.1,3,100);
    sessions = unique(tbl.session);

    p = nan(size(tbl,1),1);
    for i = 1:length(sessions)
        ix = tbl.session == sessions(i);

        action = tbl.action(ix);
        action(action==-1) = 0;
        action_diff = tbl.action_diff(ix);
        action_diff = smooth(tbl.stimulus(ix),action_diff,3); % smooth a bit to take into account state uncertainty

        if include_bias == 1
            bias = safelog(tbl.marginal(ix)) - safelog(1-tbl.marginal(ix));
            P = @(b) 1./(1+exp(-b.*action_diff - bias));
        else
            P = @(b) 1./(1+exp(-b.*action_diff));
        end
        loglik = @(b) action'*safelog(P(b)) + (1-action')*safelog(1-P(b));

        L = loglik(b);
        [LL(i),k] = max(L);
        B(i) = b(k);
        p(ix) = P(B(i));
    end