classdef FlatAdaptiveSliceGenerator < FlatUniformSliceGenerator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
              
        % Default layer profiles as provided in the Example
        % [minAngle, maxAngle, layerThickness]
        layerProfiles = [0, 65, 0.1;
                            65, 79, 0.2;
                            79, 85, 0.5;
                            85, 90, 1.0];
        
    end
    
    methods (Access = public)
        
        % Create an instance using Triangulation Data
        function obj = FlatAdaptiveSliceGenerator(data, preferedThickness)
            obj = obj@FlatUniformSliceGenerator(data, preferedThickness);
        end
        
    end
    
    methods (Access = protected)
        
        % Overrides the Uniform Slicer's Z Generator method to instead
        % create adaptive slices
        function sliceHeights = generateSliceHeights(obj)
        % Generates the Z values for which each of the flat layer slices
        % will be generated at.
        
            % Get the maximum Z height
            maxZ = max(obj.points(:, 3));
            
            % Generate a list of all the slice heights
            sliceHeights = zeros(0);
            currZ = 0;
            
            % The maximum height to check is within the range of the
            % maximum layer thickness
            maxThickness = max(obj.layerProfiles(:,3));
            
            while currZ < maxZ
               
                % Minimum Angle Predefined to 90 degress or pi/2 rads
                minAngle = pi / 2;
                
                % Checks for lowest angle on this layer within the range
                for element = 1:obj.numOfElements
                    
                    % Calculate Minimum Angle on Plane
                    [isOnPlane, angle] = obj.checkElement(element, currZ, currZ + maxThickness);
                    
                    if isOnPlane == 1
                        minAngle = min(minAngle, angle);
                    end
                     
                end
                
                % Compare minAngle against available Layer Thicknesses
                deltaZ = maxThickness;
                
                for i = 1:height(obj.layerProfiles)
                   
                    % If this angle is within the range, then set this as
                    % the delta Z
                    
                    if obj.layerProfiles(i,1) <= minAngle && minAngle < obj.layerProfiles(i,1)
                       deltaZ = obj.layerProfiles(i,3);
                       break
                    end
                    
                end
                
                % Append the current Z
                sliceHeights = [sliceHeights; deltaZ];
                
                % Increment
                currZ = currZ + deltaZ;
                
            end
            
            % Add the top layer
            sliceHeights = [sliceHeights; maxZ];
            
        end
        
        % Determines the angle of the element
        function [isOnPlane, angle] = checkElement(obj, elementNumber, minZ, maxZ)
            
            % Initalise the matrices
            angle = -1;
            
            % Parse the data for this element
            elementVertices = getElementData(obj, elementNumber);
            numOfVertices = height(elementVertices);
            
            % If any part of the element lies on the plane, process
            isOnPlane = 1;
            for vertice = 1:numOfVertices
                
                currZ = elementVertices(vertice,3);
                if (minZ <= currZ && currZ <= maxZ)
                    isOnPlane = 1;
                end
                
            end
            
            % If this element doesn't lie on the plane, return nothing
            if isOnPlane == 0
                return
            end
            
            % Otherwise, process element
            
            % Generate the Vectors for two edge U, V on the triangle
            U = elementVertices(2,:) - elementVertices(1,:);
            V = elementVertices(3,:) - elementVertices(1,:);
            
            % Generate the normal vector
            N = cross(U, V);
            
            % Analyse the Z Vector
            angleXZ = abs(atan(N(3)/N(1)));
            angleYZ = abs(atan(N(3)/N(2)));
            
            % Return the min angle
            angle = min(angleXZ, angleYZ);
            
        end
        
    end
end

