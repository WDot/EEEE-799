function X = X6( k, n )
    X = (1:n).^-3;
    X = X(randperm(n)) .* ((-1).^(binornd(1,0.5,1,n)));
    X(randperm(n,k)) = 0;
end

