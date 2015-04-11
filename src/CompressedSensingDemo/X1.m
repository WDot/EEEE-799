function X = X1( k, n )
    X = zeros(1,n);
    X(randperm(n,k)) = randn(1,k);
end

