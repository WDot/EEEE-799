classdef AdaptiveCodebook < Codebook
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
        function obj = AdaptiveCodebook(itemCount,codewordSize, range)
            obj = obj@Codebook(itemCount,codewordSize);
            obj.codebook = zeros(1,itemCount * codewordSize);
            obj.range = range;
        end
        
        function codeword = GetCodeword(self,index)
            if index < self.codewordSize
                %Assumes excitation needs to be repeated no more than 2
                %times
                numRepeats = ceil(self.codewordSize / index);
                codeword = repmat(self.codebook((end - index + 1):end),1,numRepeats);
                codeword = codeword(1:self.codewordSize);
            else
                codeword = self.codebook((end - index):(end - index + self.codewordSize - 1));
            end
        end
         
        function UpdateCode(self,codeword)
            self.codebook = [self.codebook((self.codewordSize + 1):end) codeword];
        end
    end
    
end

