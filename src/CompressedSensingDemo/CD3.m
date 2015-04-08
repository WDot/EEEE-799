function C = CD3( n )
    randomPhases = rand(1,n).*exp(2i*pi*rand(1,n));
    C = ctranspose(dftmtx(n)) * diag(randomPhases) * dftmtx(n);
end

