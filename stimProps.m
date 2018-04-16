classdef stimProps < handle
    %STIMPROPS Global properties declaration class
    %   this class contains the global properties used in the stimpack
    %   tool. An instance of this class is found in the stimCore class.
    
    properties (SetAccess = public)
        % path info
        path@char = './'
        % Device enable
        usingEyelink@logical = false
        usingDataPixx@logical = false
        usingLabJack@logical = false
        
        %psychToolbox
        ptbSkipSync@logical = false
        
        % 
        eyelinkIp@char = '10.1.1.1'
        
        %
        stimScreen@double = 0
        
        %
        rewardTime@double = 50
        
    end
    
    methods
        function obj = stimProps(args)
        end
    end
    
end

