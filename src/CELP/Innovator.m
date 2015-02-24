classdef Innovator < handle

    %Innovator - Random gaussian codebook used to feed CELP analysis/synth
    
    properties
        codebook
        index
        sequenceCount
        frameSize
    end
    
    methods
        function obj = Innovator(sequenceCount, frameSize)
            obj.index = 1;
            obj.codebook = normrnd(0,1,sequenceCount,frameSize);
            obj.sequenceCount = sequenceCount;
            obj.frameSize = frameSize;
        end
        function sequence = NextInnovation(self)
            sequence = self.codebook(self.index,:);
            if self.index < self.sequenceCount
                self.index = self.index + 1;
            else
                self.index = 1;
            end
        end

    end
    
end

