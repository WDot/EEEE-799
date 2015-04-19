function X = X7( k, n )
    y = X1(k,n);
    A = zeros(n, n);
    for i = 1:(length(A) - 1)
        A(i,i:(i+1)) = [-1, 1];
    end
    A(length(A),length(A)) = -1;
    X = linsolve(A,y')';
end

