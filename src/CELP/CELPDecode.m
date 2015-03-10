function synthVal = CELPDecode( codedFrames, stochasticCodebook )
    FRAME_SIZE = 160;
    NUM_SUB_FRAMES = 4;
    SUBFRAME_SIZE = FRAME_SIZE / NUM_SUB_FRAMES;
    FILTER_ORDER = 10;
    VALID_LAGS = 20:147;
    synthVal = zeros(1,length(stochasticCodebook) * FRAME_SIZE);
    synthCount = 1;
    lp = ShortTermPredictor(FILTER_ORDER);
    adaptiveCodebook = AdaptiveCodebook(NUM_SUB_FRAMES,SUBFRAME_SIZE,VALID_LAGS);
    for i=1:length(codedFrames)
        lp.coefficients = codedFrames(i).coefficients;
        for j = 1:NUM_SUB_FRAMES
            excitationAcb = adaptiveCodebook.GetCodeword(codedFrames(i).adaptiveCodewords(j)) * codedFrames(i).adaptiveGains(j);
            excitationScb = stochasticCodebook.GetCodeword(codedFrames(i).stochasticCodewords(j)) * codedFrames(i).stochasticGains(j);
            excitationTotal = excitationAcb + excitationScb;
            synthVal(synthCount:(synthCount + SUBFRAME_SIZE - 1)) = lp.Filter(excitationTotal);
            lp.UpdateZf();
            adaptiveCodebook.UpdateCode(excitationTotal);
            synthCount = synthCount + SUBFRAME_SIZE;
        end
    end
end

