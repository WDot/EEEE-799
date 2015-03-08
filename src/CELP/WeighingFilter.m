classdef WeighingFilter < ClosedLoopFilter
    %ShortTermPredictor - Optimum all-pole filter based on short term data 
    
    properties
        coefficients2
        zf
        testZf
    end
    
    
    methods
        function obj = WeighingFilter(filterOrder)
            obj = obj@ClosedLoopFilter(filterOrder);
            obj.coefficients2 = zeros(1,filterOrder);
            obj.zf = zeros(1,filterOrder - 1);
        end
        
        function UpdateFilter(self,coeffs)
            %BANDWIDTH EXPANSION
            self.coefficients = coeffs;
            self.coefficients2 = coeffs .* (.85) .^(0:(length(coeffs) - 1));
        end
        
        function output = Filter(self,buffer)
            [output,self.testZf] = filter(self.coefficients,self.coefficients2,buffer,self.zf);
        end
        
        function output = InverseFilter(self,buffer)
            [output,self.testZf] = filter(self.coefficients2,self.coefficients,buffer,self.zf);
        end
        
        function UpdateZf(self)
            self.zf = self.testZf;
        end
    end
    
end

