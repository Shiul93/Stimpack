classdef stimCore < handle
    %NOT USED
    %STIMCORE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        props
    end
    
    methods
        function this = stimCore(args)
            this.props = stimProps();
            this.props.path = pwd();
        end
    end
    
end

