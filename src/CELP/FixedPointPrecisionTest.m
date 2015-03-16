function quantizationMSE = FixedPointPrecisionTest( codedFrames, sCodebook,testVector )
    MAX_BITS_RANGE = 5:16;
    FIXED_POINT_DECIMAL_BITS_RANGE = 0:14;
    quantizationMSE = zeros(length(MAX_BITS_RANGE),length(FIXED_POINT_DECIMAL_BITS_RANGE));
    codeValTest = CodeFrame.CodeFrameArray(length(codedFrames));
    tvPower = mean(testVector.^2);
    for maxBits = MAX_BITS_RANGE
        for Qs = 0:(maxBits - 2)
            for i = 1:length(codedFrames)
                codeValTest(i) = codedFrames(i).Copy();
                codeValTest(i).CoeffsToFixedPoint(Qs,maxBits);
                codeValTest(i).CoeffsFromFixedPoint(Qs);
                codeValTest(i).GainsToFixedPoint(Qs,maxBits);
                codeValTest(i).GainsFromFixedPoint(Qs);
            end
            synthValQuantized = CELPDecode(codeValTest,sCodebook);
            quantizationMSE(maxBits - 4,Qs + 1) = mean((synthValQuantized - testVector').^2)/tvPower;
        end
    end
end

