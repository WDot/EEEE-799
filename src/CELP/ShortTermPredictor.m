classdef ShortTermPredictor < ClosedLoopFilter
    %ShortTermPredictor - Optimum all-pole filter based on short term data 
    
    properties
        testZf
        zf
    end
    
    
    methods
        function obj = ShortTermPredictor(filterOrder)
            obj = obj@ClosedLoopFilter(filterOrder);
            obj.zf = zeros(1,filterOrder - 1);
        end
        
        function UpdateFilter(self,buffer)
            positiveTimeLags = xcorr(buffer,'biased');
            positiveTimeLags = positiveTimeLags(length(buffer):end);
            self.coefficients =  levinson(positiveTimeLags,length(self.coefficients) - 1);
            self.coefficients = self.coefficients .* (.9) .^(0:(length(self.coefficients) - 1));
            
        end
        
        function output = Filter(self,buffer)
            output = filter(1,self.coefficients,buffer);  
        end
        
        function UpdateZf(self)
            self.zf = self.testZf;
        end
    end
    
end

