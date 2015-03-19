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
[codeVal,synthVal] = CELPEncode(testVector,stochasticCodebook);
%Comparison of different fixed-point quantizations
quantizationMSE = FixedPointPrecisionTest(codeVal,stochasticCodebook,testVector);
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
[optimumFPPMSE,optimumFPPkBps,synthVals] = CoefficientGainSameQuantizationTest(codeVal,stochasticCodebook,testVector);
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
[optimumFPPMSEVarying,optimumFPPkBpsVarying,synthValsVarying] = CoefficientGainDiffQuantizationTest(codeVal,stochasticCodebook,testVector);
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

figure(6);
plot(1:length(testVector),testVector,'r',1:length(testVector),synthVal,'b');
title('Syntheses (Red is original, blue is coded)');
xlabel('Sample');
ylabel('Magnitude');
mse = mean((testVector - synthVal).^2)/mean(testVector.^2);
fprintf('MSE: %f\n',mse);