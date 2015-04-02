function mu = Coherence( sensingBasis, representationBasis, n )
    maxCorr = 0;
    for i=1:length(sensingBasis)
        for j=1:length(representationBasis)
            correlation = abs((sensingBasis(i,:)* ...
                representationBasis(j,:)')/(norm(sensingBasis(i,:))...
                *norm(representationBasis(j,:))));
            if correlation > maxCorr
                maxCorr = correlation;
            end
        end
    end
    mu = sqrt(n)*maxCorr;
end

