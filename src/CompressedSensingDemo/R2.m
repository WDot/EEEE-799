function C = R2( n )
    firstRow = binornd(1,.5,1,n);
    C = zeros(n);
    for i = 1:n
        C(i,:) = circshift(firstRow,[0,i - 1]);
    end
end

