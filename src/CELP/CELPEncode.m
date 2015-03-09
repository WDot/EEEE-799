function [codeVal,synthVal] = CELPEncode(testVector)
%Hardcoded parameters
FRAME_SIZE = 160;
SUBFRAME_SIZE = FRAME_SIZE / 4;
FILTER_ORDER = 10;
CODEBOOK_SIZE = 512;
VALID_LAGS = 20:147;
%Cheat a little bit, make the vector exactly 160N long
testVector = double(testVector(1:(floor(length(testVector) / FRAME_SIZE) * FRAME_SIZE)));
synthVal = zeros(size(testVector));
%Create the tools for analysis/synthesis
lp = ShortTermPredictor(FILTER_ORDER);
W = WeighingFilter(FILTER_ORDER);
[bHpf,aHpf] = butter(10,.01,'high');
adaptiveCodebook   = zeros(1,160);
stochasticCodebook = randn(CODEBOOK_SIZE,SUBFRAME_SIZE);
tic
for frameIndex=1:FRAME_SIZE:length(testVector)
    frame = testVector(frameIndex:(frameIndex + FRAME_SIZE - 1));
    lp.UpdateFilter(frame);
    W.UpdateFilter(lp.coefficients);
    %LTP
    for subframeIndex=1:SUBFRAME_SIZE:FRAME_SIZE
        %generate target error
        zir = lp.Filter(zeros(1,SUBFRAME_SIZE));
        subframe = frame(subframeIndex:(subframeIndex + SUBFRAME_SIZE -1))';
        subframe = filter(bHpf,aHpf,subframe);
        targetErrorAcb = W.InverseFilter(lp.InverseFilter(subframe - zir));
        bestGainAcb = 0;
        bestMatchAcb = 0;
        bestExcitationAcb = zeros(1,SUBFRAME_SIZE);
        
        %search Adaptive Codebook for best excitation
        for j = VALID_LAGS
            if j < SUBFRAME_SIZE
                %Assumes excitation needs to be repeated no more than 2
                %times
                numRepeats = ceil(SUBFRAME_SIZE / j);
                excitationAcb = repmat(adaptiveCodebook((end - j + 1):end),1,numRepeats);
                excitationAcb = excitationAcb(1:SUBFRAME_SIZE);
            else
                excitationAcb = adaptiveCodebook((end - j):(end - j + SUBFRAME_SIZE - 1));
            end
            y = excitationAcb;
            correlationAcb = y * targetErrorAcb';
            energyAcb = y * y';
            gainAcb = (correlationAcb) / (energyAcb);
            if isnan(gainAcb)
                gainAcb = 0;
            end
            match = abs(gainAcb);
            if match > bestMatchAcb
                bestGainAcb = gainAcb;
                bestMatchAcb = match;
                bestExcitationAcb = excitationAcb;
            end
        end
        bestExcitationAcb = bestGainAcb * bestExcitationAcb;
        targetErrorScb = targetErrorAcb - bestExcitationAcb;
        bestGainScb = 0;
        bestMatchScb = 0;
        bestExcitationScb = zeros(1,SUBFRAME_SIZE);
        %search Stochastic Codebook for best excitation
        for j = 1:CODEBOOK_SIZE
            excitationScb = stochasticCodebook(j,:);
            y = excitationScb;
            correlationScb = y * targetErrorScb';
            energyScb = y * y';
            gainScb = (correlationScb) / (energyScb);
            match = abs(gainScb);
            if match > bestMatchScb
                bestGainScb = gainScb;
                bestMatchScb = match;
                bestExcitationScb = excitationScb;
            end
        end
        bestExcitationScb = bestGainScb * bestExcitationScb;
        bestExcitationTotal = bestExcitationScb + bestExcitationAcb;
        adaptiveCodebook = [adaptiveCodebook((SUBFRAME_SIZE + 1):end) bestExcitationTotal];
        synthVal((frameIndex + subframeIndex - 1):(frameIndex + subframeIndex + SUBFRAME_SIZE -2)) = lp.Filter(bestExcitationTotal);
        lp.UpdateZf();
        W.UpdateZf();
    end
end
toc
codeVal = 0;
fprintf('MSE: %f\n',mean((testVector - synthVal).^2));
BOUNDS=1:length(testVector);

plot(BOUNDS,testVector(BOUNDS),'r',BOUNDS,synthVal(BOUNDS),'b');
title('Synthesis (Red is original, blue is synthesized)');
xlabel('Sample');
ylabel('Magnitude');