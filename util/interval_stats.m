function [m,se,X,q] = interval_stats(x,y,q,fun)
    
    % Compute statistics for dependent variable conditioned on intervals of
    % an independent variable
    
    if length(q)==1
        q = linspace(min(y),max(y),q);
    end
    
    if nargin < 4
        fun = @nanmean;
    end
    
    for i = 1:length(q)-1
        ix = y>q(i) & y<=q(i+1);
        X{i} = x(ix);
        m(i) = fun(x(ix));
        se(i) = nanstd(x(ix))./sqrt(sum(~isnan(x(ix))));
    end

    q = q(1:end-1) + diff(q)/2;