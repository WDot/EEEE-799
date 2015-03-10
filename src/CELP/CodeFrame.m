classdef CodeFrame < handle
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
        
        function binaryString = GetCode(self)
            binaryString = '';
        end
    end
    
end

