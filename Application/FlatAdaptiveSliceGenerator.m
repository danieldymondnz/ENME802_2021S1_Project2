classdef FlatAdaptiveSliceGenerator < FlatUniformSliceGenerator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
              
        % Default layer profiles as provided in the Example
        % [minAngle, maxAngle, layerThickness]
        layerProfiles = [0, 65, 0, 0.2, 0.1;
                            65, 79, 0.2, 0.5, 0.2;
                            79, 85, 0.5, 1.0, 0.5;
                            85, 90, 1.5, 1e12, 1.0];
        
        % Stores the important information about each element
        % [angleToXYPlane, minZ, maxZ]
        adaptiveSlicerElementInformation (:,3) double 
        
    end
    
    methods (Access = public)
        
        % Create an instance using Triangulation Data
        function obj = FlatAdaptiveSliceGenerator(data, preferedThickness)
            obj = obj@FlatUniformSliceGenerator(data, preferedThickness);
        end
        
        % Determines the angle of the element
%         function [isOnPlane, angle, residualHeight] = checkElement(obj, elementNumber, currZ, minZ, maxZ)
%         % Determines the residual height of the element relative to the
%         % current slice and the element's angle relative to the x-y plane
%             
%             % Initalise values
%             isOnPlane = 0;
%             angle = 0;
%             residualHeight = 0;
%             
%             % Parse the data for this element
%             elementVertices = getElementData(obj, elementNumber);
%             numOfVertices = height(elementVertices);
%             
%             % If any part of the element lies on the plane, process
%             for vertice = 1:numOfVertices
%                 
%                 n1 = vertice;
%                 n2 = vertice + 1;
%                 
%                 if (vertice >= numOfVertices)
%                     n2 = 1;
%                 end
%                     
%                 z1 = elementVertices(n1,3);
%                 z2 = elementVertices(n2,3);
%                 
%                 if ((z1 <= minZ && minZ <= z2) || (minZ <= z1 && z2 <= minZ))
%                     
%                     isOnPlane = 1;
%                     continue;
%                     
%                 elseif ((z1 <= maxZ && maxZ <= z2) || (maxZ <= z1 && z2 <= maxZ))
%                     
%                     isOnPlane = 1;
%                     continue;
%                     
%                 end
%                 
%             end
%             
%             % If this element doesn't lie on the plane, return nothing
%             if isOnPlane == 0
%                 return
%             end
%             
%             % Otherwise, process element
%             
%             % Generate the Vectors for two edge U, V on the triangle
%             U = elementVertices(2,:) - elementVertices(1,:);
%             V = elementVertices(3,:) - elementVertices(1,:);
%             
%             % Generate the normal vector
%             N = cross(U, V);
%             N = N/norm(N);
%             
%             % Analyse the Z Vector
%             angleXZ = abs(atan(N(3)/N(1)));
%             angleYZ = abs(atan(N(3)/N(2)));
%             
%             % Return the min angle
%             angle = (pi/2) - min(angleXZ, angleYZ);
%             
%         end
        
        % Generates and stores the information for the
        % adaptiveSlicerElementInformation matrix.
        function generateAdaptiveSlicerElementInformation(obj)
           
            % Initalise the matrix
            obj.adaptiveSlicerElementInformation =[];
            
            % For each element, generate the necessary information
            for element = 1:obj.numOfElements
                
                % Get the element information
                elementVertices = getElementData(obj, element);
                    
                % Calculate the normal angle of this element to the XY
                % Plane
                angleToZ = obj.determineAngleToZ(elementVertices);
                
                % Determine the minimum Z Value
                minEleZ = min(elementVertices(:,3));
                
                % Determine the maximum Z Value
                maxEleZ = max(elementVertices(:,3));
                
                % Write to the matrix
                obj.adaptiveSlicerElementInformation = ...
                    [obj.adaptiveSlicerElementInformation; angleToZ, minEleZ, maxEleZ];
                
            end
            
        end
        
    end
    
    methods (Access = protected)
        
        % Overrides the Uniform Slicer's Z Generator method to instead
        % create adaptive slices
        function sliceHeights = generateSliceHeights(obj)
        % Generates the Z values for which each of the flat layer slices
        % will be generated at.
        
            % Generate Element Information
            generateAdaptiveSlicerElementInformation(obj);
        
            % Get the maximum Z height
            maxZ = max(obj.points(:, 3));
            
            % Generate a list of all the slice heights
            sliceHeights = [];
            currZ = 0;
            
            % The maximum height to check is within the range of the
            % maximum layer thickness
            maxThickness = max(obj.layerProfiles(:,5));
            while currZ < maxZ
               
                % Minimum Angle Predefined to 90 degrees
                minAngle = 90;
                minResidualHeight = maxThickness;
                
                % Checks for lowest angle on this layer within the range
                for element = 1:obj.numOfElements
                    
                    % Get element information
                    information = obj.adaptiveSlicerElementInformation(element,1:3);
                    angleToXYPlane = information(1,1);
                    minEleZ = information(1,2);
                    maxEleZ = information(1,3);
                    
                    % If element lies in the plane area
                    if ~((maxEleZ < currZ) || (minEleZ > currZ))%(minEleZ <= currZ && currZ + maxThickness <= maxEleZ)
                        
                       % Set the new minAngle
                        minAngle = min(minAngle, angleToXYPlane);

                        % Set the new minResidualHeight
                        elementResidHeight = maxThickness;
                        if (currZ < maxEleZ && maxEleZ < currZ + maxThickness)
                            elementResidHeight = maxEleZ - currZ;
                        end   
                        minResidualHeight = min(minResidualHeight,elementResidHeight);
                        
                    end

                    
                     
                end
                
                % Compare minAngle against available Layer Thicknesses
                deltaZ = maxThickness;
                for i = 1:height(obj.layerProfiles)
                   
                    % If this angle is within the range, then set this as
                    % the delta Z
                    if obj.layerProfiles(i,1) <= minAngle && minAngle < obj.layerProfiles(i,2)
                       deltaZ = obj.layerProfiles(i,5);
                       break
                    end
                    
                end
                
                % Compare residualHeight against available Layer Thicknesses
                for i = 1:height(obj.layerProfiles)
                   
                    % If this angle is within the range, compare and set to
                    % deltaZ
                    if obj.layerProfiles(i,3) <= minResidualHeight && minResidualHeight < obj.layerProfiles(i,4)
                       deltaZ = min(deltaZ, obj.layerProfiles(i,5));
                       break
                    end
                    
                end
                
                % Append the current Z
                sliceHeights = [sliceHeights; currZ];
                
                % Increment
                currZ = currZ + deltaZ;
                
            end
            
            % Add the top layer
            sliceHeights = [sliceHeights; maxZ];
            
        end
           
        function angleToZ = determineAngleToZ(obj, elementVertices)
           
            % Generate two vectors
            U = elementVertices(2,:) - elementVertices(1,:);
            V = elementVertices(3,:) - elementVertices(1,:);

            % Find the Cross Product
            N = cross(U,V);
            N = N/norm(N);

            % If vector is pointing down, flip to point up
            if N(1,3) < 0
                N(1,:) = N(1,:) * -1;
            end

            % Find the Dot Product to a unit vector for Z
            Z = [0 0 1];
            dotProduct = dot(N,Z);

            % Find the angle between the two vectors
            angleToZ = abs(acosd(dotProduct / (norm(N) * norm(Z))));

        end
    end
end

