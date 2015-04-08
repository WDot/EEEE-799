function C = CD2( n )
    randomPhases = ConjugateSymmetric1D(n);
    C = ctranspose(dftmtx(n)) * diag(randomPhases) * dftmtx(n);
end

