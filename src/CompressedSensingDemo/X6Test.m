function [results,stdError] = X6Test( count, range, m, n )
    Cs = {@R1,@R1,@R2,@CD1,@CD2,@CD3,@I1,@I2};
    Ps = {@P1,@P3,@P1,@P3,@P3,@P3,@P3,@P3};
    results = zeros(length(Cs),length(range));
    stdError = zeros(length(Cs),length(range));
    for line = 1:length(Cs)
        for k = range
            samples = zeros(length(range),count);
            for i = 1:count
                samplingVector = Ps{line}(n,m)*Cs{line}(n);
                sparseVector = X6(k,n)';
                underSampledVector = samplingVector * sparseVector;
                cvx_begin quiet
                    variable x(n)
                    minimize( norm(x,1) )
                    subject to
                        samplingVector*x == underSampledVector;
                cvx_end
                samples(k - min(k) + 1,count) = norm(x - sparseVector,2) / norm(sparseVector,2);
            end
            results(line,k - min(k) + 1) = mean(samples(k - min(k) + 1,:));
            stdError(line,k - min(k) + 1) = std(samples(k - min(k) + 1,:))/sqrt(count);
        end
    end
end


