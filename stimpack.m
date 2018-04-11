classdef stimpack < handle
   
    %STIMPACK Visual stimulation tool
    %   Visual stimulation tool for primates based on Psychtoolbox
    
    properties
        props@stimProps
    end
    
    % PUBLIC METHODS
    methods
        % Class contructor
        function obj = stimpack(varargin)
			
            obj.props = stimProps();
			obj.initialiseGUI;
            obj.props.path

			
        end
    end
    
    % HIDDEN METHODS
    methods (Hidden = true)
        function initialiseGUI(obj) 
            stimGUI()
        end
    end
    
end

