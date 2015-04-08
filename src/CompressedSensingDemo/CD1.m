function C = CD1( n )
    %each complex random number has magnitude 1
    randomPhases = ConjugateSymmetric1D(n);
    randomPhases = randomPhases ./ abs(randomPhases);
    C = ctranspose(dftmtx(n)) * diag(randomPhases) * dftmtx(n);
end

