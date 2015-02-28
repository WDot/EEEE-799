%Hardcoded parameters
FRAME_SIZE = 160;
SUBFRAME_SIZE = FRAME_SIZE / 4;
FILTER_ORDER = 10;
CODEBOOK_SIZE = 512;
%Make ready the input and output files
[pathstr,~,~] = fileparts(mfilename('fullpath'));
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
testVector = testVector(1:(floor(length(testVector) / FRAME_SIZE) * FRAME_SIZE));
synthVal = zeros(size(testVector));
%Create the tools for analysis/synthesis
lp = ShortTermPredictor(FILTER_ORDER);
W = WeighingFilter(FILTER_ORDER);
%Adaptive codebook has random garbage to start in order to prevent divide
%by zero errors, should quickly be replaced with real data

adaptiveCodebook   = randn(1,160);
stochasticCodebook = randn(CODEBOOK_SIZE,SUBFRAME_SIZE);
for frameIndex=1:FRAME_SIZE:length(testVector)
    frame = testVector(frameIndex:(frameIndex + FRAME_SIZE - 1))'.*hamming(FRAME_SIZE)';
    lp.UpdateFilter(frame);
    W.UpdateFilter(lp.coefficients);
    %LTP
    for subframeIndex=1:SUBFRAME_SIZE:FRAME_SIZE
        %generate target error
        zir = lp.Filter(zeros(1,SUBFRAME_SIZE));
        subframe = frame(subframeIndex:(subframeIndex + SUBFRAME_SIZE -1)).*hamming(SUBFRAME_SIZE)';
        targetErrorAcb = W.Filter(subframe - zir);
        bestGainAcb = 0;
        bestMatchAcb = 0;
        bestExcitationAcb = zeros(1,SUBFRAME_SIZE);
        %search Adaptive Codebook for best excitation
        for j = 20:147
            if j < SUBFRAME_SIZE
                excitationAcb = padarray(adaptiveCodebook((end - j):end),[0 SUBFRAME_SIZE - j - 1],'circular','post');
            else
                excitationAcb = adaptiveCodebook((end - j):(end - j + SUBFRAME_SIZE - 1));
            end
            y = W.Filter(lp.Filter(excitationAcb));
            gainAcb = (y * targetErrorAcb') / (y * y');
            match = (y * targetErrorAcb').^2 /(y * y');
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
            y = W.Filter(lp.Filter(excitationScb));
            gainScb = (y * targetErrorScb') / (y * y');
            match = (y * targetErrorScb').^2 /(y * y');
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
    end
end

BOUNDS=1:length(testVector);

plot(BOUNDS,testVector(BOUNDS),'r',BOUNDS,synthVal(BOUNDS),'b');