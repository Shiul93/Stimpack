classdef stimpack < stimCore
   
    %STIMPACK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    % PUBLIC METHODS
    methods
        % Class contructor
        function this = stimpack(varargin)
			
            
			this=this@stimCore(varargin); %superclass constructor
			
			this.initialiseGUI;
            ip = this.props.eyelinkIp;

			
        end
    end
    
    % HIDDEN METHODS
    methods (Hidden = true)
        function initialiseGUI(this) 
            stimGUI()
        end
    end
    
end

