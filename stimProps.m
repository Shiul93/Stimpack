classdef stimProps < handle
    %STIMPROPS Global properties declaration class
    %   this class contains the global properties used in the stimpack
    %   tool. An instance of this class is found in the stimCore class.
    
    properties (SetAccess = public)
        % path info
        path@char = './'
        % Device enable
        usingEyelink@logical = true
        usingDataPixx@logical = true
        usingLabJack@logical = true
        
        %psychToolbox
        ptbSkipSync@logical = false
        
        % 
        eyelinkIp@char = '10.1.1.1'
        
        %
        stimScreen@double = 1
        
        %
        rewardTime@double = 100
        
    end
    
    methods
        function obj = stimProps(args)
        end
    end
    
end

