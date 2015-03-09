function [bestCodeword,bestGain] = CodebookSearch( nextCodeFunc, target, range )
    bestGain = 0;
    bestMatch = -1;
    bestCodeword = 0;
    for j = range
        y = nextCodeFunc(j);
        correlationAcb = y * target';
        energyAcb = y * y';
        gainAcb = (correlationAcb) / (energyAcb + eps);
        match = abs(gainAcb);
        if match > bestMatch
            bestGain = gainAcb;
            bestMatch = match;
            bestCodeword = j;
        end
    end
end

