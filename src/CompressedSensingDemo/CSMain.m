BLOCK_SIZE = 160;
THRESHOLD  = 0.005;
SAMPLE_SEQUENCE = 0:(BLOCK_SIZE - 1);
[pathstr,~,~] = fileparts(mfilename('fullpath'));
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
testVector = testVector(1:(floor(length(testVector) / BLOCK_SIZE) * BLOCK_SIZE));
testVector = testVector(1:BLOCK_SIZE);
representationBasis = dctmtx(BLOCK_SIZE);
samplingBasis = randn(BLOCK_SIZE);
sparseVector = representationBasis * testVector;
sparseVector(abs(sparseVector) <= THRESHOLD) = 0;
S = length(find(sparseVector > 0)); %Calculate S-sparseness
coherence = Coherence(representationBasis,samplingBasis,BLOCK_SIZE);
m = 110;
sampleRows = randperm(BLOCK_SIZE);
sampleRows = sampleRows(1:m);
underSampledVector = samplingBasis(sampleRows,:) * sparseVector;
opts = optimoptions('fmincon','Algorithm','interior-point');
x = fmincon(@(x)norm(x,1),zeros(1,BLOCK_SIZE),[],[],...
    samplingBasis(sampleRows,:),underSampledVector,-Inf,Inf,[],opts);
plot(SAMPLE_SEQUENCE,sparseVector,SAMPLE_SEQUENCE,x);
legend('Original','Reconstructed');