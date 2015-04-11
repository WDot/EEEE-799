function P = P3( n, m )
    P = eye(n);
    P = P(randperm(n,m),:);
end

