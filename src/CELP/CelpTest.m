[pathstr,~,~] = fileparts(mfilename('fullpath'));
FRAME_SIZE = 160;
innovator = Innovator(100,FRAME_SIZE);
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
%for short-term laziness, make the testVector length a multiple of 160
padding = (ceil(length(testVector) / FRAME_SIZE) * FRAME_SIZE) - length(testVector);
testVector = padarray(testVector,[padding, 0],'post');
synthVal = zeros(size(testVector));
stp = ShortTermPredictor(20);
errors = zeros(1,innovator.sequenceCount);
excitation = zeros(100,FRAME_SIZE);
 for j = 1:FRAME_SIZE:length(testVector)
     tv = testVector(j:(j + FRAME_SIZE - 1))';
     stp.UpdateFilter(tv);
     for i = 1:innovator.sequenceCount
         excitation(i,:) = innovator.NextInnovation + PitchPrediction(tv,Fs);
         errors(i) = mean((tv - stp.Filter(excitation(i,:))).^2);
         [bestError, bestErrorLoc] = min(errors);
         synthVal(j:(j + FRAME_SIZE - 1)) = excitation(bestErrorLoc,:);
     end
 end

%PitchPrediction(tv,Fs)