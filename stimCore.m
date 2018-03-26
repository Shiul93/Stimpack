classdef stimCore < handle
    %STIMCORE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = public)
        props
    end
    
    methods
        function this = stimCore(args)
            this.props = stimProps();
        end
    end
    
end

