classdef FlatAdaptiveSliceGenerator < FlatUniformSliceGenerator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        
    end
    
    methods (Access = public)
        
        % Create an instance using Triangulation Data
        function obj = FlatAdaptiveSliceGenerator(data, preferedThickness)
            obj = obj@FlatUniformSliceGenerator(data, preferedThickness);
        end
        
    end
end

