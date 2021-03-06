function [results,stdError] = X5Test( count, m, n )
    Cs = {@R1,@R1,@R2,@CD1,@CD2,@CD3,@I1,@I2};
    Ps = {@P1,@P3,@P1,@P3,@P3,@P3,@P3,@P3};
    results = zeros(length(Cs),length(0:8));
    stdError = zeros(length(Cs),length(0:8));
    k = 8;
    for line = 1:length(Cs)
        for noiseArg = 0:8
            samples = zeros(length(noiseArg),count);
            for i = 1:count
                samplingVector = Ps{line}(n,m)*Cs{line}(n);
                sparseVector = X5(k,n,noiseArg)';
                underSampledVector = samplingVector * sparseVector;
                cvx_begin quiet
                    variable x(n)
                    minimize( norm(x,1) )
                    subject to
                        samplingVector*x == underSampledVector;
                cvx_end
                samples(noiseArg + 1,count) = norm(x - sparseVector,2) / norm(sparseVector,2);
            end
            results(line,noiseArg + 1) = mean(samples(noiseArg + 1,:));
            stdError(line,noiseArg + 1) = std(samples(noiseArg + 1,:))/sqrt(count);
        end
    end
end


