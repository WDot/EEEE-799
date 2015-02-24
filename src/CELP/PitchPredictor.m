classdef PitchPredictor < handle
    
    properties
        Fs
        coefficients
    end
    
    
    methods
        function obj = PitchPredictor(Fs)
           obj.Fs = Fs;
        end
        
        function UpdateFilter(self,buffer)

            %Not robust to noise, does not take into account pitch
            %periods wider than the buffer, does not take into account phase
            autoCorrLpf = fir1(20,pi/8);
            positiveTimeLags = xcorr(buffer,'biased');
            positiveTimeLags = positiveTimeLags(length(buffer):end);
            %LPF to get rid of spurious peaks, 0 phase
            positiveTimeLags = filtfilt(autoCorrLpf,1,positiveTimeLags);

            [~, locs] = findpeaks(positiveTimeLags);
            f0lag = min(locs);
            if isempty(f0lag)
                f0lag = 1;
            end
            %Get fundamental frequency from period bin
            f0 = 1/ (f0lag / self.Fs);
            %Get frequency bin from frequency
            f0bin = round(length(buffer) * f0 / self.Fs);
            gain = abs(goertzel(buffer,f0bin)) / length(buffer);
            self.coefficients = zeros(1,f0lag);
            self.coefficients(1) = 1;
            self.coefficients(end) = 1;
        end
        
        function output = Filter(self,buffer)
            output = filter(1,self.coefficients,buffer);
        end
    end
    
end

