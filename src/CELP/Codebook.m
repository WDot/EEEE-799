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
        
        function [bestCodeword,bestGain] = Search(self,target)
            bestGain = 0;
            bestMatch = -1;
            bestCodeword = 0;
            for j = self.range
                y = self.GetCodeword(j);
                correlationAcb = y * target';
                energyAcb = y * y';
                gainAcb = (correlationAcb) / (energyAcb + eps);
                match = abs(gainAcb);
                if match > bestMatch
                    bestGain = gainAcb;
                    bestMatch = match;
                    bestCodeword = j;
                end
            end
        end
    end
end

