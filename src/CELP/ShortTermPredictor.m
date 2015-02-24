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
            
        end
        
        function output = Filter(self,buffer)
            output = filter(1,self.coefficients,buffer);
        end
    end
    
end

