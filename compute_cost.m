function [cost, marginal, surprisal] = compute_cost(stimulus,action)
    
    % Compute trial-by-trial policy cost, marginal distribution, and surprisal

    [S,~,si] = unique(stimulus);
    [A,~,ai] = unique(action);
    alpha = 0.1;

    nSA = zeros(length(S),length(A));
    for s = 1:length(S)
        for a = 1:length(A)
            nSA(s,a) = sum(stimulus==S(s) & action==A(a)) + alpha;
        end
    end

    pSA = nSA./sum(nSA(:));
    pS = sum(pSA,2);
    pA = sum(pSA);

    cost = zeros(size(stimulus));
    surprisal = zeros(size(stimulus));

    if nargout > 1
        marginal = zeros(size(stimulus)) + pA(2);
    end

    for i = 1:length(stimulus)
        cost(i) = log(pSA(si(i),ai(i))) - log(pS(si(i))) - log(pA(ai(i)));
        surprisal(i) = -log(pA(ai(i)));
    end