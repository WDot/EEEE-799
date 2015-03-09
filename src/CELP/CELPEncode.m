function [codeVal,synthVal] = CELPEncode(testVector)
%Hardcoded parameters
FRAME_SIZE = 160;
NUM_SUB_FRAMES = 4;
SUBFRAME_SIZE = FRAME_SIZE / NUM_SUB_FRAMES;
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
adaptiveCodebook   = AdaptiveCodebook(NUM_SUB_FRAMES,SUBFRAME_SIZE,VALID_LAGS);
stochasticCodebook = StochasticCodebook(CODEBOOK_SIZE,SUBFRAME_SIZE);
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
        %search Adaptive Codebook for best excitation
        [bestCodewordAcb,bestGainAcb] = CodebookSearch(@adaptiveCodebook.GetCodeword,targetErrorAcb,adaptiveCodebook.range);
        bestExcitationAcb = bestGainAcb * adaptiveCodebook.GetCodeword(bestCodewordAcb);
        targetErrorScb = targetErrorAcb - bestExcitationAcb;
        %search Stochastic Codebook for best excitation
        [bestCodewordScb,bestGainScb] = CodebookSearch(@stochasticCodebook.GetCodeword,targetErrorScb,stochasticCodebook.range);
        bestExcitationScb = bestGainScb * stochasticCodebook.GetCodeword(bestCodewordScb);
        bestExcitationTotal = bestExcitationScb + bestExcitationAcb;
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