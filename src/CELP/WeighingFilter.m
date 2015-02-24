classdef WeighingFilter < ClosedLoopFilter
    %ShortTermPredictor - Optimum all-pole filter based on short term data 
    
    properties
        coefficients2
    end
    
    
    methods
        function obj = WeighingFilter(filterOrder)
            obj = obj@ClosedLoopFilter(filterOrder);
            obj.coefficients2 = zeros(1,filterOrder);
        end
        
        function UpdateFilter(self,coeffs)
            for i = 1:length(self.coefficients)
                self.coefficients(i)  = coeffs(i) / (.9)^(i - 1);
                self.coefficients2(i) = coeffs(i) / (.5)^(i - 1);
            end
        end
        
        function output = Filter(self,buffer)
            output = filter(self.coefficients,self.coefficients2,buffer);
        end
    end
    
end

