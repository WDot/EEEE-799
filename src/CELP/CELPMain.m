%Make ready the input and output files
[pathstr,~,~] = fileparts(mfilename('fullpath'));
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
[codeVal,synthVal] = CELPEncode(testVector);