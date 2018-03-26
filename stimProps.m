classdef stimProps < handle
    %STIMPROPS Global properties declaration class
    %   this class contains the global properties used in the stimpack
    %   tool. An instance of this class is found in the stimCore class.
    
    properties (SetAccess = public)
        % Device enable
        usingEyelink = false
        usingDataPixx = false
        usingLabJack = false
        
        % 
        eyelinkIp = ''
        
    end
    
    methods
        function this = stimProps(args)
        end
    end
    
end

