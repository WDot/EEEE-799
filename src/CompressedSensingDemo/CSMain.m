BLOCK_SIZE = 160;
THRESHOLD  = 0.005;
[pathstr,~,~] = fileparts(mfilename('fullpath'));
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
testVector = testVector(1:(floor(length(testVector) / BLOCK_SIZE) * BLOCK_SIZE));
testVector = testVector(1:160);
representationBasis = dctmtx(BLOCK_SIZE);
samplingBasis = randn(BLOCK_SIZE);
sparseVector = representationBasis * testVector;
sparseVector(abs(sparseVector) <= THRESHOLD) = 0;
S = length(find(sparseVector > 0)); %Calculate S-sparseness
coherence = Coherence(representationBasis,samplingBasis,BLOCK_SIZE);
necessarySamples = coherence^2 * S * log(BLOCK_SIZE);