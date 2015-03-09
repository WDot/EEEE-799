classdef (Abstract) ClosedLoopFilter < handle
    %ClosedLoopFilter - Any filter updated by feedback data
    
    properties
        coefficients
        zf
        zfCandidate
    end
    
    methods (Abstract)
        UpdateFilter(self,buffer)
        Filter(self,buffer)
        InverseFilter(self,buffer)
    end
    
    methods
        function obj = ClosedLoopFilter(filterOrder)
            obj.coefficients = zeros(1,filterOrder);
            obj.zf = zeros(1,filterOrder - 1);
            obj.zfCandidate = zeros(1,filterOrder - 1);
        end
        
        function UpdateZf(self)
            self.zf = self.zfCandidate;
        end
    end
end

