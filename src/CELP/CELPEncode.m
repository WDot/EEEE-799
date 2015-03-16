function [codedFrames,synthVal] = CELPEncode(testVector,stochasticCodebook)
    %Hardcoded parameters
    FRAME_SIZE = 160;
    NUM_SUB_FRAMES = 4;
    SUBFRAME_SIZE = FRAME_SIZE / NUM_SUB_FRAMES;
    FILTER_ORDER = 10;
    VALID_LAGS = 20:147;
    numFrames = length(testVector) / FRAME_SIZE;
    codedFrames = CodeFrame.CodeFrameArray(numFrames);
    synthVal = zeros(size(testVector));
    %Create the tools for analysis/synthesis
    lp = ShortTermPredictor(FILTER_ORDER);
    W = WeighingFilter(FILTER_ORDER);
    adaptiveCodebook   = AdaptiveCodebook(NUM_SUB_FRAMES,SUBFRAME_SIZE,VALID_LAGS);
    frameCount = 1;
    tic
    for frameIndex=1:FRAME_SIZE:length(testVector)
        frame = testVector(frameIndex:(frameIndex + FRAME_SIZE - 1));
        lp.UpdateFilter(frame);
        W.UpdateFilter(lp.coefficients);
        %LTP
        subFrameCount = 1;
        codedFrames(frameCount).coefficients = lp.coefficients;
        for subframeIndex=1:SUBFRAME_SIZE:FRAME_SIZE
            %generate target error
            zir = lp.Filter(zeros(1,SUBFRAME_SIZE));
            subframe = frame(subframeIndex:(subframeIndex + SUBFRAME_SIZE -1))';
            targetErrorAcb = W.InverseFilter(lp.InverseFilter(subframe - zir));
            %search Adaptive Codebook for best excitation
            [bestCodewordAcb,bestGainAcb] = adaptiveCodebook.Search(targetErrorAcb);
            bestExcitationAcb = bestGainAcb * adaptiveCodebook.GetCodeword(bestCodewordAcb);
            targetErrorScb = targetErrorAcb - bestExcitationAcb;
            %search Stochastic Codebook for best excitation
            [bestCodewordScb,bestGainScb] = stochasticCodebook.Search(targetErrorScb);
            bestExcitationScb = bestGainScb * stochasticCodebook.GetCodeword(bestCodewordScb);
            bestExcitationTotal = bestExcitationScb + bestExcitationAcb;
            synthVal((frameIndex + subframeIndex - 1):(frameIndex + subframeIndex + SUBFRAME_SIZE -2)) = lp.Filter(bestExcitationTotal);
            codedFrames(frameCount).adaptiveCodewords(subFrameCount) = bestCodewordAcb;
            codedFrames(frameCount).adaptiveGains(subFrameCount) = bestGainAcb;
            codedFrames(frameCount).stochasticCodewords(subFrameCount) = bestCodewordScb;
            codedFrames(frameCount).stochasticGains(subFrameCount) = bestGainScb;
            lp.UpdateZf();
            W.UpdateZf();
            adaptiveCodebook.UpdateCode(bestExcitationTotal);
            subFrameCount = subFrameCount + 1;
        end
        frameCount = frameCount + 1;
    end
    toc
end