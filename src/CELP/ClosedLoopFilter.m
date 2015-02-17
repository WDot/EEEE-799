classdef (Abstract) ClosedLoopFilter < handle
    %ClosedLoopFilter - Any filter updated by feedback data
    
    properties
        coefficients
    end
    
    methods (Abstract)
        UpdateFilter(self,buffer)
        Filter(self,buffer)
    end
    
    methods
        function obj = ClosedLoopFilter(filterOrder)
            obj.coefficients = zeros(1,filterOrder);
        end
    end
end

