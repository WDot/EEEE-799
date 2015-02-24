[pathstr,~,~] = fileparts(mfilename('fullpath'));
FRAME_SIZE = 160;
SUBFRAME_SIZE = FRAME_SIZE / 4;
CODEBOOK_SIZE = 512;
FILTER_ORDER = 40;
innovator = Innovator(CODEBOOK_SIZE,SUBFRAME_SIZE);
[testVector, Fs] = audioread(strcat(pathstr,'/../../testvectors/test.wav'));
%for short-term laziness, make the testVector length a multiple of 160
padding = (ceil(length(testVector) / FRAME_SIZE) * FRAME_SIZE) - length(testVector);
testVector = testVector(1:16160);
synthVal = zeros(size(testVector));
stp = ShortTermPredictor(FILTER_ORDER);
pitchPredictor = PitchPredictor(Fs);
weighFilter = WeighingFilter(FILTER_ORDER);
errors = zeros(1,CODEBOOK_SIZE);
excitation = zeros(CODEBOOK_SIZE,SUBFRAME_SIZE);
 for currentFrame = 1:FRAME_SIZE:length(testVector)
     
     tv = testVector(currentFrame:(currentFrame + FRAME_SIZE - 1))'.*hamming(FRAME_SIZE)';
     pitchPredictor.UpdateFilter(tv);
     for subFrame = currentFrame:SUBFRAME_SIZE:(currentFrame + FRAME_SIZE - 1)
         stv = testVector(subFrame:(subFrame + SUBFRAME_SIZE - 1))'.*hamming(SUBFRAME_SIZE)';
         stp.UpdateFilter(stv);
         weighFilter.UpdateFilter(stp.coefficients);
         for currentCodebookValue = 1:CODEBOOK_SIZE
             code = innovator.NextInnovation;
             %scale codebook value to match signal
             gain = sqrt(mean(stv.^2)) / sqrt(mean(code.^2));
             code = code * gain;
             excitation(currentCodebookValue,:) = stp.Filter(pitchPredictor.Filter(code));
             errorSignal = stv - excitation(currentCodebookValue,:);
             errors(currentCodebookValue) = mean((errorSignal).^2);
             [bestError, bestErrorLoc] = min(errors);
             synthVal(subFrame:(subFrame + SUBFRAME_SIZE - 1)) = excitation(bestErrorLoc,:);
         end
     end
 end
 
 fprintf('MSE: %f\n',mean((testVector - synthVal).^2));
 
 hold on;
 figure(1);
 plot(testVector(1:50));
 plot(synthVal(1:50),'r');
 hold off;
% figure(2);
% plot(innovator.NextInnovation)

%PitchPrediction(tv,Fs)