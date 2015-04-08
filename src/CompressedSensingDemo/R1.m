function C = R1( n )
    firstRow = randn(1,n);
    C = zeros(n);
    for i = 1:n
        C(i,:) = circshift(firstRow,[0,i - 1]);
    end
end

