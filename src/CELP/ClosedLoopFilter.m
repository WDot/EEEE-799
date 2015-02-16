classdef (Abstract) ClosedLoopFilter < handle
    
    properties
        coefficients
    end
    
    methods (Abstract)
        UpdateFilter(self,buffer)
        Filter(self,buffer)
    end
    
end

