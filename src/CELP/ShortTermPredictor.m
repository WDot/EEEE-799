classdef ShortTermPredictor < ClosedLoopFilter
    %ShortTermPredictor - Optimum all-pole filter based on short term data 
    
    properties
    end
    
    
    methods
        function obj = ShortTermPredictor(filterOrder)
            obj = obj@ClosedLoopFilter(filterOrder);
        end
        
        function UpdateFilter(self,buffer)
            positiveTimeLags = xcorr(buffer,'biased');
            positiveTimeLags = positiveTimeLags(length(buffer):end);
            self.coefficients =  levinson(positiveTimeLags,length(self.coefficients) - 1);
            self.coefficients = self.coefficients .* (.9) .^(0:(length(self.coefficients) - 1));
            
        end
        
        function output = Filter(self,buffer)
            [output,self.zfCandidate] = filter(1,self.coefficients,buffer,self.zf);  
        end
        
        function output = InverseFilter(self,buffer)
            [output,self.zfCandidate] = filter(self.coefficients,1,buffer,self.zf);  
        end
    end
    
end

