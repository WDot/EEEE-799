classdef Codebook < handle

    properties
        count
        codewordSize
        codebook
        range
    end
    
    methods (Abstract)
        GetCodeword(index);
    end
    
    methods
        function obj = Codebook(itemCount,codewordSize)
            obj.count = itemCount;
            obj.codewordSize = codewordSize;
        end
    end
    
end

