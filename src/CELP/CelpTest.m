[pathstr,~,~] = fileparts(mfilename('fullpath'));
innovator = Innovator(100,160);
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
stp = ShortTermPredictor(20);
tv = testVector(1:160)';
stp.UpdateFilter(tv);
errors = zeros(1,innovator.sequenceCount);
for i = 1:innovator.sequenceCount
    errors(i) = mean((tv - stp.Filter(innovator.NextInnovation)).^2);
end