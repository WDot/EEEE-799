function results = X7Test( count, range, m, n )
    Cs = {@R1,@R1,@R2,@CD1,@CD2,@CD3,@I1,@I2};
    Ps = {@P1,@P3,@P1,@P3,@P3,@P3,@P3,@P3};
    results = zeros(length(Cs),length(range));
    for k = range
        for i = 1:count
            for line = 1:length(Cs)
                samplingVector = Ps{line}(n,m)*Cs{line}(n);
                sparseVector = X7(k,n)';
                underSampledVector = samplingVector * sparseVector;
                cvx_begin quiet
                    variable x(n)
                    minimize( norm(x(2:n) - x(1:(n-1)),1) )
                    subject to
                        samplingVector*x == underSampledVector;
                cvx_end
                error = norm(x - sparseVector,2) / norm(sparseVector,2);
                if error < 1e-3
                    results(line,k - min(range) + 1) = results(line,k - min(range) + 1) + 1;
                end
            end
        end
    end
end


