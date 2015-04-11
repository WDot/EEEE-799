function X = X5( k,n,i )
    X = X1(k,n) + normrnd(0,10e-4 * 2^i,1,n);
end

