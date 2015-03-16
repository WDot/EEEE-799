%Make ready the input and output files
CODEBOOK_SIZE = 512;
FRAME_SIZE = 160;
NUM_SUB_FRAMES = 4;
SUBFRAME_SIZE = FRAME_SIZE / NUM_SUB_FRAMES;
FILTER_ORDER = 10;
MAX_BITS_RANGE = 5:16;
FIXED_POINT_DECIMAL_BITS_RANGE = 0:14;
MAX_BITS_OFFSET = -4;
OPTIMUM_FPP_OFFSET = -2; 
[pathstr,~,~] = fileparts(mfilename('fullpath'));
stochasticCodebook = StochasticCodebook(CODEBOOK_SIZE,SUBFRAME_SIZE);
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
%Cheat a little bit, make the vector exactly 160N long
testVector = testVector(1:(floor(length(testVector) / FRAME_SIZE) * FRAME_SIZE));
tvPower = mean(testVector.^2);
[codeVal,synthVal] = CELPEncode(testVector,stochasticCodebook);
codeValTest = CodeFrame.CodeFrameArray(length(codeVal));
%Comparison of different fixed-point quantizations
quantizationMSE = zeros(length(MAX_BITS_RANGE),length(FIXED_POINT_DECIMAL_BITS_RANGE));
for maxBits = MAX_BITS_RANGE
    for Qs = 0:(maxBits - 2)
        for i = 1:length(codeValTest)
            codeValTest(i) = codeVal(i).Copy();
            codeValTest(i).CoeffsToFixedPoint(Qs,maxBits);
            codeValTest(i).CoeffsFromFixedPoint(Qs);
            codeValTest(i).GainsToFixedPoint(Qs,maxBits);
            codeValTest(i).GainsFromFixedPoint(Qs);
        end
        synthValQuantized = CELPDecode(codeValTest,stochasticCodebook);
        quantizationMSE(maxBits - 4,Qs + 1) = mean((synthValQuantized - testVector').^2)/tvPower;
    end
end
figure(1);
hold all;
for maxBits = MAX_BITS_RANGE
    plot(0:maxBits-2,quantizationMSE(maxBits + MAX_BITS_OFFSET,(0:maxBits-2) + 1));
end
legend('5-bit','6-bit','7-bit','8-bit','9-bit','10-bit','11-bit','12-bit','13-bit','14-bit','15-bit','16-bit');
title('Normalized MSE of Quantized Coefficients and Gains with varying Fixed-Point Precisions')
xlabel('Fixed-point Decimal bits of precision');
ylabel('MSE divided by original signal power');
hold off;
%comparison of bitrates if gains and excitations have the same encoding
synthVals = zeros(length(5:16),length(synthVal));
optimumFPPMSE = zeros(1,length(MAX_BITS_RANGE));
optimumFPPkBps = zeros(1,length(MAX_BITS_RANGE));
for maxBits = 5:16
    for i = 1:length(codeValTest)
        codeValTest(i) = codeVal(i).Copy();
        codeValTest(i).CoeffsToFixedPoint(maxBits - 2,maxBits);
        codeValTest(i).CoeffsFromFixedPoint(maxBits - 2);
        codeValTest(i).GainsToFixedPoint(maxBits - 2,maxBits);
        codeValTest(i).GainsFromFixedPoint(maxBits - 2);
    end
    synthVals(maxBits + MAX_BITS_OFFSET,:) = CELPDecode(codeValTest,stochasticCodebook);
    optimumFPPMSE(maxBits + MAX_BITS_OFFSET) = mean((synthVals(maxBits + MAX_BITS_OFFSET,:) - testVector').^2)/tvPower;
    optimumFPPkBps(maxBits + MAX_BITS_OFFSET) = (maxBits*(FILTER_ORDER + 2*NUM_SUB_FRAMES) + 16*NUM_SUB_FRAMES) * 50 /1000;
end
figure(2)
plot(MAX_BITS_RANGE,optimumFPPMSE);
title('Normalized MSE per N bits of quantization, assuming N - 2 fixed-point decimal bits')
xlabel('Bits per Coefficient/Gain');
ylabel('MSE divided by original signal power');
figure(3)
plot(MAX_BITS_RANGE,optimumFPPkBps);
title('Code kBps per N bits of quantization, assuming N - 2 fixed-point decimal bits')
xlabel('Bits per Coefficient/Gain');
ylabel('kBps (20ms/frame times 50 frames)');
%comparison of bitrates when varying gain and coefficient quantization
optimumFPPMSEVarying = zeros(length(MAX_BITS_RANGE));
optimumFPPkBpsVarying = zeros(length(MAX_BITS_RANGE));
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
        optimumFPPkBpsVarying(maxBitsCoeffs + MAX_BITS_OFFSET,maxBitsGains + MAX_BITS_OFFSET) = (maxBitsCoeffs*(FILTER_ORDER) + maxBitsGains*2*NUM_SUB_FRAMES + 16*NUM_SUB_FRAMES) * 50 /1000;
        optimumFPPMSEVarying(maxBitsCoeffs + MAX_BITS_OFFSET,maxBitsGains + MAX_BITS_OFFSET) = mean((synthValsVary - testVector').^2)/tvPower;
    end
end
figure(4);
hold all;
%5 and 6 bit quantizations of coefficients have large error, lead to
%unstable results
for maxBits = 7:16
    plot(MAX_BITS_RANGE,optimumFPPMSEVarying(maxBits + MAX_BITS_OFFSET,:));
end
legend('7-bit','8-bit','9-bit','10-bit','11-bit','12-bit','13-bit','14-bit','15-bit','16-bit');
title('Normalized MSE of Quantized Coefficients with varying Quantizations of Gains')
xlabel('Bits in Quantized Gain');
ylabel('MSE divided by original signal power');
hold off;
figure(5);
hold all;
for maxBits = MAX_BITS_RANGE
    plot(MAX_BITS_RANGE,optimumFPPkBpsVarying(maxBits + MAX_BITS_OFFSET,:));
end
legend('5-bit','6-bit','7-bit','8-bit','9-bit','10-bit','11-bit','12-bit','13-bit','14-bit','15-bit','16-bit');
title('Code kBps of Quantized Coefficients with varying Quantizations of Gains')
xlabel('Bits in Quantized Gain');
ylabel('kBps (20ms/frame times 50 frames)');
hold off;

% BOUNDS=1:length(synthVal);
% figure(2);
% plot(BOUNDS,synthVal(BOUNDS),'r',BOUNDS,synthVal2(BOUNDS),'b');
% title('Syntheses (Red is Unquantized, blue is Quantized)');
% xlabel('Sample');
% ylabel('Magnitude');
%16-bit coefficients, 16-bit gains