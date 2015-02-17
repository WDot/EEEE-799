classdef ShortTermPredictor < ClosedLoopFilter
    %ShortTermPredictor - Optimum all-pole filter based on short term data 
    
    properties
    end
    
    
    methods
        function obj = ShortTermPredictor(filterOrder)
            obj = obj@ClosedLoopFilter(filterOrder);
        end
        
        function UpdateFilter(self,buffer)
                       
            self.coefficients =  levinson(toeplitz(xcorr(buffer,'biased')),length(self.coefficients));
            
        end
        
        function output = Filter(self,buffer)
            output = filter(1,self.coefficients,buffer);
        end
    end
    
end

