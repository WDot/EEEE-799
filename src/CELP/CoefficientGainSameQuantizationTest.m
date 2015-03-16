function [optimumFPPMSE, optimumFPPkBps] = CoefficientGainSameQuantizationTest( codedFrames, sCodebook,testVector )
    MAX_BITS_RANGE = 5:16;
    FILTER_ORDER = 10;
    NUM_SUB_FRAMES = 4;
    MAX_BITS_OFFSET = -4;
    optimumFPPMSE = zeros(1,length(MAX_BITS_RANGE));
    optimumFPPkBps = zeros(1,length(MAX_BITS_RANGE));
    codeValTest = CodeFrame.CodeFrameArray(length(codedFrames));
    tvPower = mean(testVector.^2);
    for maxBits = MAX_BITS_RANGE
        for i = 1:length(codedFrames)
            codeValTest(i) = codedFrames(i).Copy();
            codeValTest(i).CoeffsToFixedPoint(maxBits - 2,maxBits);
            codeValTest(i).CoeffsFromFixedPoint(maxBits - 2);
            codeValTest(i).GainsToFixedPoint(maxBits - 2,maxBits);
            codeValTest(i).GainsFromFixedPoint(maxBits - 2);
        end
        synthVal = CELPDecode(codeValTest,sCodebook);
        optimumFPPMSE(maxBits + MAX_BITS_OFFSET) = mean((synthVal - testVector').^2)/tvPower;
        optimumFPPkBps(maxBits + MAX_BITS_OFFSET) = (maxBits*(FILTER_ORDER + 2*NUM_SUB_FRAMES) + 16*NUM_SUB_FRAMES) * 50 /1000;
    end
end

