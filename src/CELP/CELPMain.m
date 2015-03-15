%Make ready the input and output files
CODEBOOK_SIZE = 512;
FRAME_SIZE = 160;
NUM_SUB_FRAMES = 4;
SUBFRAME_SIZE = FRAME_SIZE / NUM_SUB_FRAMES;
FILTER_ORDER = 10;
[pathstr,~,~] = fileparts(mfilename('fullpath'));
stochasticCodebook = StochasticCodebook(CODEBOOK_SIZE,SUBFRAME_SIZE);
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
[codeVal,synthVal] = CELPEncode(testVector,stochasticCodebook);
codeValTest = CodeFrame.CodeFrameArray(length(codeVal));

%Comparison of different fixed-point quantizations
for maxBits = 5:16
    for Qs = 0:(maxBits - 2)
        for i = 1:length(codeValTest)
            codeValTest(i) = codeVal(i).Copy();
            codeValTest(i).CoeffsToFixedPoint(Qs,maxBits);
            codeValTest(i).CoeffsFromFixedPoint(Qs);
            codeValTest(i).GainsToFixedPoint(Qs,maxBits);
            codeValTest(i).GainsFromFixedPoint(Qs);
        end
        synthVal2 = CELPDecode(codeValTest,stochasticCodebook);
        fprintf('Quantization MSE: %f Q: %d Bits: %d\n',mean((synthVal2 - synthVal').^2),Qs,maxBits);
    end
end
%comparison of bitrates if gains and excitations have the same encoding
synthVals = zeros(length(5:16),length(synthVal));
for maxBits = 5:16
    for i = 1:length(codeValTest)
        codeValTest(i) = codeVal(i).Copy();
        codeValTest(i).CoeffsToFixedPoint(maxBits - 2,maxBits);
        codeValTest(i).CoeffsFromFixedPoint(maxBits - 2);
        codeValTest(i).GainsToFixedPoint(maxBits - 2,maxBits);
        codeValTest(i).GainsFromFixedPoint(maxBits - 2);
    end
    synthVals(maxBits - 4,:) = CELPDecode(codeValTest,stochasticCodebook);
    kBps = (maxBits*(FILTER_ORDER + 2*NUM_SUB_FRAMES) + 16*NUM_SUB_FRAMES) * 50 /1000;
    fprintf('Quantization MSE: %f Q: %d Bits: %d kBps: %f\n',mean((synthVals(maxBits - 4,:) - synthVal').^2),maxBits - 2,maxBits,kBps);
end
%comparison of bitrates when varying gain and coefficient quantization
for maxBitsCoeffs = 5:16
    for maxBitsGains = 5:16
        for i = 1:length(codeValTest)
            codeValTest(i) = codeVal(i).Copy();
            codeValTest(i).CoeffsToFixedPoint(maxBitsCoeffs - 2,maxBitsCoeffs);
            codeValTest(i).CoeffsFromFixedPoint(maxBitsCoeffs - 2);
            codeValTest(i).GainsToFixedPoint(maxBitsGains - 2,maxBitsGains);
            codeValTest(i).GainsFromFixedPoint(maxBitsGains - 2);
        end
        synthValsVary = CELPDecode(codeValTest,stochasticCodebook);
        kBps = (maxBitsCoeffs*(FILTER_ORDER) + maxBitsGains*2*NUM_SUB_FRAMES + 16*NUM_SUB_FRAMES) * 50 /1000;
        fprintf('Quantization MSE: %f Bits_Gains: %d Bits_Coeffs: %d kBps: %f\n',mean((synthValsVary - synthVal').^2),maxBitsGains,maxBitsCoeffs,kBps);
    end
end


BOUNDS=1:length(synthVal);
figure(2);
plot(BOUNDS,synthVal(BOUNDS),'r',BOUNDS,synthVal2(BOUNDS),'b');
title('Syntheses (Red is Unquantized, blue is Quantized)');
xlabel('Sample');
ylabel('Magnitude');
%16-bit coefficients, 16-bit gains