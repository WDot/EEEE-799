%Make ready the input and output files
CODEBOOK_SIZE = 512;
FRAME_SIZE = 160;
NUM_SUB_FRAMES = 4;
SUBFRAME_SIZE = FRAME_SIZE / NUM_SUB_FRAMES;
[pathstr,~,~] = fileparts(mfilename('fullpath'));
stochasticCodebook = StochasticCodebook(CODEBOOK_SIZE,SUBFRAME_SIZE);
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
[codeVal,synthVal] = CELPEncode(testVector,stochasticCodebook);
synthVal2 = CELPDecode(codeVal,stochasticCodebook);