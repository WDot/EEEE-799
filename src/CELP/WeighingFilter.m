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
            %BANDWIDTH EXPANSION
            self.coefficients = coeffs;
            self.coefficients2 = coeffs .* (.85) .^(0:(length(coeffs) - 1));
        end
        
        function output = Filter(self,buffer)
            [output,self.zfCandidate] = filter(self.coefficients,self.coefficients2,buffer,self.zf);
        end
        
        function output = InverseFilter(self,buffer)
            [output,self.zfCandidate] = filter(self.coefficients2,self.coefficients,buffer,self.zf);
        end
    end
    
end

