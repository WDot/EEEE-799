function d = ConjugateSymmetric1D( n )
    d = zeros(1,n);
    left = 0;
    right = n - left;
    while left <= right
        if (left + 1) == mod(right + 1,n)
            %generate a real number, since it is  its own complex conjugate
            d(left + 1) = rand(1);
        else
            d(left + 1) = rand(1).*exp(2i*pi*rand(1));
            d(right + 1) = conj(d(left+1));
        end
        left = left + 1;
        right = n - left;
    end
end

