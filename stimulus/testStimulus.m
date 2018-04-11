classdef testStimulus < AbstractStimulus
    %TESTSTIMULUS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        edfFile@char = 'asd'
    end
    
    methods
        function obj = testStimulus(a)
            obj.props = a('props');

        end
        function runStimulus(obj)
            obj.setupScreen()
            obj.configureEyelink()
            obj.connectToEyelink()
            obj.startEyelink()
            
            
            
        end
    end
    
end

