function [pitchSignal, pitches, locs] = PitchPrediction( buffer, Fs)
    
    %Not robust to noise, does not take into account pitch
    %periods wider than the buffer, does not take into account phase
    b = fir1(20,pi/8);
    positiveTimeLags = xcorr(buffer,'biased');
    positiveTimeLags = positiveTimeLags(length(buffer):end);
    %LPF to get rid of spurious peaks, 0 phase
    positiveTimeLags = filtfilt(b,1,positiveTimeLags);
    
    [pitches, locs] = findpeaks(positiveTimeLags);
    f0lag = min(locs);
    if isempty(f0lag)
        f0lag = 1;
    end
    %Get fundamental frequency from period bin
    f0 = 1/ (f0lag / Fs);
    %Get frequency bin from frequency
    f0bin = round(length(buffer) * f0 / Fs);
    lol = filtfilt(b,1,abs(fft(buffer)));
    gain = abs(goertzel(buffer,f0bin)) / length(buffer);
    pitchSignal = gain*sin((2*pi*f0/Fs)*(0:(length(buffer) - 1)));
%    figure(1)
%    plot(positiveTimeLags);
%    figure(2)
%    plot(lol)
%    figure(3)
%    plot(pitchSignal)
end

