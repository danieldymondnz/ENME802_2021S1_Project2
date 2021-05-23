classdef FlatAdaptiveSliceGenerator < FlatUniformSliceGenerator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        
        minThickness = 0.05;
        maxThickness = 0.25;
        
    end
    
    methods (Access = public)
        
        % Create an instance using Triangulation Data
        function obj = FlatAdaptiveSliceGenerator(data, preferedThickness)
            obj = obj@FlatUniformSliceGenerator(data, preferedThickness);
        end
    end
    
    methods (Access = protected)
        
        % Overrides the Uniform Slicer
        function sliceHeights = generateSliceHeights(obj)
        % Generates the Z values for which each of the flat layer slices
        % will be generated at.
        
            % Get the maximum Z height
            maxZ = max(obj.points(:, 3));
            
            % Generate a list of all the slice heights
            sliceHeights = zeros(0);
            currZ = 0;
            
            while currZ < maxZ
               
                sliceHeights = [sliceHeights; currZ];
                currZ = currZ + obj.sliceThickness;
                
            end
            
            % Add the top layer
            sliceHeights = [sliceHeights; maxZ];
            
        end
        
    end
end

