%Hardcoded parameters
FRAME_SIZE = 160;
SUBFRAME_SIZE = FRAME_SIZE / 4;
FILTER_ORDER = 10;
CODEBOOK_SIZE = 512;
SCALE_FACTOR = 4;
VALID_LAGS = 2:147;
%Make ready the input and output files
[pathstr,~,~] = fileparts(mfilename('fullpath'));
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
testVector = double(testVector(1:(floor(length(testVector) / FRAME_SIZE) * FRAME_SIZE)));
synthVal = zeros(size(testVector));
%Create the tools for analysis/synthesis
lp = ShortTermPredictor(FILTER_ORDER);
W = WeighingFilter(FILTER_ORDER);
%Adaptive codebook has random garbage to start in order to prevent divide
%by zero errors, should quickly be replaced with real data
[bHpf,aHpf] = butter(10,.01,'high');
adaptiveCodebook   = zeros(1,160);
%adaptiveCodebookInterp = zeros(1,length(adaptiveCodebook)*SCALE_FACTOR);
stochasticCodebook = max(-1,(min(1,ceil(randn(CODEBOOK_SIZE,SUBFRAME_SIZE)))))*max(testVector);
tic
for frameIndex=1:FRAME_SIZE:length(testVector)
    frame = testVector(frameIndex:(frameIndex + FRAME_SIZE - 1))'.*hamming(FRAME_SIZE)';
    lp.UpdateFilter(frame);
    W.UpdateFilter(lp.coefficients);
    %LTP
    for subframeIndex=1:SUBFRAME_SIZE:FRAME_SIZE
        %generate target error
        zir = lp.Filter(zeros(1,SUBFRAME_SIZE));
        subframe = frame(subframeIndex:(subframeIndex + SUBFRAME_SIZE -1)).*hamming(SUBFRAME_SIZE)';
        subframe = filter(bHpf,aHpf,subframe);
        targetErrorAcb = W.Filter(subframe - zir);
        bestGainAcb = 0;
        bestMatchAcb = 0;
        bestExcitationAcb = zeros(1,SUBFRAME_SIZE);
        
        gainGraph = zeros(1,length(VALID_LAGS));
        matchGraph = zeros(1,length(VALID_LAGS));
        %search Adaptive Codebook for best excitation
        for j = VALID_LAGS
            if j < SUBFRAME_SIZE
                %Assumes excitation needs to be repeated no more than 2
                %times
                excitationAcb = repmat(adaptiveCodebook((end - j + 1):end),1,20);
                excitationAcb = excitationAcb(1:SUBFRAME_SIZE);
            else
                excitationAcb = adaptiveCodebook((end - j):(end - j + SUBFRAME_SIZE - 1));
            end
            y = W.Filter(lp.Filter(excitationAcb));
            correlationAcb = y * targetErrorAcb';
            energyAcb = y * y';
            gainAcb = (correlationAcb) / (energyAcb);
            if isnan(gainAcb)
                gainAcb = 0;
            end
            match = gainAcb * correlationAcb;
            gainGraph(j - 2 + 1) = gainAcb;
            matchGraph(j - 2 + 1) = match;
            if match > bestMatchAcb
                bestGainAcb = gainAcb;
                bestMatchAcb = match;
                bestExcitationAcb = excitationAcb;
            end
        end
%         figure(1);
%         plot(subframe);
%         title('Subframe');
%         figure(2);
%         plot(VALID_LAGS,gainGraph);
%         title('Gain');
%         figure(3);
%         plot(VALID_LAGS,matchGraph);
%         title('Match');
%         figure(4);
%         plot(targetErrorAcb);
%         title('Target error');
%         bestExcitationAcb = bestGainAcb * bestExcitationAcb;
%         figure(5);
%         plot(bestExcitationAcb);
%         title('Best Excitation');
        targetErrorScb = targetErrorAcb - W.Filter(lp.Filter(bestExcitationAcb));
        bestGainScb = 0;
        bestMatchScb = 0;
        bestExcitationScb = zeros(1,SUBFRAME_SIZE);
        %search Stochastic Codebook for best excitation
        for j = 1:CODEBOOK_SIZE
            excitationScb = stochasticCodebook(j,:);
            y = W.Filter(lp.Filter(excitationScb));
            correlationScb = y * targetErrorScb';
            energyScb = y * y';
            gainScb = (correlationScb) / (energyScb);
            match = gainScb * correlationScb;
            if match > bestMatchScb
                bestGainScb = gainScb;
                bestMatchScb = match;
                bestExcitationScb = excitationScb;
            end
        end
        bestExcitationScb = bestGainScb * bestExcitationScb;
        bestExcitationTotal = bestExcitationScb + bestExcitationAcb;
        adaptiveCodebook = [adaptiveCodebook((SUBFRAME_SIZE + 1):end) bestExcitationTotal];
%        adaptiveCodebookInterp = interp(adaptiveCodebook,SCALE_FACTOR);
        synthVal((frameIndex + subframeIndex - 1):(frameIndex + subframeIndex + SUBFRAME_SIZE -2)) = lp.Filter(bestExcitationTotal);
        lp.UpdateZf();
        W.UpdateZf();
    end
end
toc
%synthVal = synthVal / max(synthVal);
fprintf('MSE: %f\n',mean((testVector - synthVal).^2));
BOUNDS=1:length(testVector);

plot(BOUNDS,testVector(BOUNDS),'r',BOUNDS,synthVal(BOUNDS),'b');
title('Synthesis (Red is original, blue is synthesized)');
xlabel('Sample');
ylabel('Magnitude');

% [b,a] = butter(10,.8);
% testVector2 = filter(b,a,testVector);
% plot(BOUNDS,fftshift(fft(testVector(BOUNDS))),'r',BOUNDS,fftshift(fft(synthVal(BOUNDS))),'b');