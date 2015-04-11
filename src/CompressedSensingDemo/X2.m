function X = X2( k, n )
    %Is it really bernoulli distributed if we enforce k-sparseness?
    X = binornd(1,0.5,1,n);
    nonzeroIndices = find(X);
    zeroIndices = find(X == 0);
    if length(nonzeroIndices) > k
        toZeroIndices = nonzeroIndices(randperm(length(nonzeroIndices),...
            length(nonzeroIndices) - k));
        X(toZeroIndices) = 0;
    elseif length(zeroIndices) > (n - k)
        toOneIndices = zeroIndices(randperm(length(zeroIndices),...
            length(zeroIndices) - (n - k)));
        X(toOneIndices) = 1;
    end
end

