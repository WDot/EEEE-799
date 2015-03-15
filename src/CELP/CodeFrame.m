classdef CodeFrame < matlab.mixin.Copyable
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        coefficients
        adaptiveCodewords
        adaptiveGains
        stochasticCodewords
        stochasticGains
    end
    
    methods(Static)
        function objs = CodeFrameArray(count)
            for i = count:-1:1
                objs(1,i) = CodeFrame();
            end
        end
    end
    
    methods
        function obj = CodeFrame()
            FILTER_ORDER = 10;
            NUM_SUB_FRAMES = 4;
            obj.coefficients = zeros(1,FILTER_ORDER);
            obj.adaptiveCodewords = zeros(1,NUM_SUB_FRAMES);
            obj.adaptiveGains = zeros(1,NUM_SUB_FRAMES);
            obj.stochasticCodewords = zeros(1,NUM_SUB_FRAMES);
            obj.stochasticGains = zeros(1,NUM_SUB_FRAMES);
        end
        
        function obj = Copy(self)
            obj = CodeFrame();
            obj.coefficients = self.coefficients;
            obj.adaptiveCodewords = self.adaptiveCodewords;
            obj.adaptiveGains = self.adaptiveGains;
            obj.stochasticCodewords = self.stochasticCodewords;
            obj.stochasticGains = self.stochasticGains;
        end
        
        function CoeffsToFixedPoint(self,Q,maxBits)
            %Q6
            self.coefficients = min(2^(abs(maxBits)),max(-2^(abs(maxBits)),int16(round(self.coefficients * 2^Q))));
        end
        
        function GainsToFixedPoint(self,Q,maxBits)
            self.adaptiveGains = min(2^(abs(maxBits)),max(-2^(abs(maxBits)),int16(round(self.adaptiveGains * 2^Q))));
            self.stochasticGains = min(2^(abs(maxBits)),max(-2^(abs(maxBits)),int16(round(self.stochasticGains * 2^Q))));
        end
        
        function CoeffsFromFixedPoint(self,Q)
            self.coefficients = double(self.coefficients) / 2^Q;
        end
        
        function GainsFromFixedPoint(self,Q)
            self.adaptiveGains = double(self.adaptiveGains) / 2^Q;
            self.stochasticGains = double(self.stochasticGains) / 2^Q;
        end
        
    end
    
end

