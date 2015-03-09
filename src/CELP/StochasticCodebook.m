classdef StochasticCodebook < Codebook
    
    properties
    end
    
    methods
        function obj = StochasticCodebook(itemCount,codewordSize)
            obj = obj@Codebook(itemCount,codewordSize);
            obj.codebook = randn(itemCount,codewordSize);
            obj.range = 1:itemCount;
        end
        
        function codeword = GetCodeword(self,index)
            if index <= self.count
                codeword = self.codebook(index,:);
            else
                codeword = 0;
            end
        end
    end
    
end

