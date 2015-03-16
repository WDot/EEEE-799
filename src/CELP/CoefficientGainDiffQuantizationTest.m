function [ optimumFPPMSEVarying,optimumFPPkBpsVarying ] = CoefficientGainDiffQuantizationTest( codedFrames, sCodebook,testVector )
    MAX_BITS_RANGE = 5:16;
    FILTER_ORDER = 10;
    NUM_SUB_FRAMES = 4;
    MAX_BITS_OFFSET = -4;
    optimumFPPMSEVarying = zeros(length(MAX_BITS_RANGE));
    optimumFPPkBpsVarying = zeros(length(MAX_BITS_RANGE));
    codeValTest = CodeFrame.CodeFrameArray(length(codedFrames));
    tvPower = mean(testVector.^2);
    for maxBitsCoeffs = MAX_BITS_RANGE
        for maxBitsGains = MAX_BITS_RANGE
            for i = 1:length(codeValTest)
                codeValTest(i) = codedFrames(i).Copy();
                codeValTest(i).CoeffsToFixedPoint(maxBitsCoeffs - 2,maxBitsCoeffs);
                codeValTest(i).CoeffsFromFixedPoint(maxBitsCoeffs - 2);
                codeValTest(i).GainsToFixedPoint(maxBitsGains - 2,maxBitsGains);
                codeValTest(i).GainsFromFixedPoint(maxBitsGains - 2);
            end
            synthValsVary = CELPDecode(codeValTest,sCodebook);
            optimumFPPkBpsVarying(maxBitsCoeffs + MAX_BITS_OFFSET,maxBitsGains + MAX_BITS_OFFSET) = (maxBitsCoeffs*(FILTER_ORDER) + maxBitsGains*2*NUM_SUB_FRAMES + 16*NUM_SUB_FRAMES) * 50 /1000;
            optimumFPPMSEVarying(maxBitsCoeffs + MAX_BITS_OFFSET,maxBitsGains + MAX_BITS_OFFSET) = mean((synthValsVary - testVector').^2)/tvPower;
        end
    end
end

