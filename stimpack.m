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
            obj.props.path = pwd;
            obj.initialiseGUI();

			
        end
    end
    
    % HIDDEN METHODS
    methods (Hidden = true)
        function initialiseGUI(obj) 
            stimGUI(obj)
        end
    end
    
%     methods (Static)
%         function singleton = getInstance
%              persistent local
%              if isempty(local)
%                 local = stimpack();
%              end
%              singleton = local;
%         end
%         function run
%             sp = stimpack.getInstance();
%             sp.initialiseGUI()
%         end
%             
%         
%     end
    
end

