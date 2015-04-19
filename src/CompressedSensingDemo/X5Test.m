function [results,stdError] = X5Test( count, m, n )
    Cs = {@R1,@R1,@R2,@CD1,@CD2,@CD3,@I1,@I2};
    Ps = {@P1,@P3,@P1,@P3,@P3,@P3,@P3,@P3};
    results = zeros(length(Cs),length(0:8));
    stdError = zeros(length(Cs),length(0:8));
    k = 8;
    for line = 1:length(Cs)
        for noiseArg = 0:8
        %RESET SAMPLES EVERY TIME, FIX WHEN RESULTS/STDERR ARE SET
            samples = zeros(length(0:8),count);
            for i = 1:count
                samplingVector = Ps{line}(n,m)*Cs{line}(n);
                sparseVector = X5(k,n,noiseArg)';
                underSampledVector = samplingVector * sparseVector;
    %               cvx_begin quiet
    %                   variable x(n)
    %                   minimize( norm(samplingVector*x-underSampledVector,2) + norm(x,1) )
    %               cvx_end
    %               error = norm(x - sparseVector,2) / norm(sparseVector,2);
                samples(noiseArg,count) = 5;
            end
            results(line,noiseArg) = mean(samples(noiseArg,:));
            stdError(line,noiseArg) = std(samples(noiseArg,:))/sqrt(count);
        end
    end
end


