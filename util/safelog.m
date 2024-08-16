function y = safelog(x)
    
    x(x==0) = 0.001;
    y = log(x);