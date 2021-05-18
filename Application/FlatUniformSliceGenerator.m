%   Flat Uniform Slice Generator (FlatUniformSliceGenerator.m)
%   Uses Original Code to generate equations for Slices at Uniform
%   Thickness

classdef FlatUniformSliceGenerator
    
    properties (SetAccess = protected)
        
        % Reference to this object
        obj;
        
        % The Connectivity List defining the nodes of each Element, and the
        % points which represent the coordinate of each node.
        connectivityList(:,:) double
        numOfElements int64
        points(:,:) int64
        
        % The Uniform Slice Thickness for each slice - default is 0.2
        sliceThickness = 0.2;
        
        % Stores the slicer path points for this object
        slicePath(:,3) double
        
    end
    
    methods
        
        % Create an instance using Triangulation Data
        function obj = FlatUniformSliceGenerator(data, preferedThickness)
            obj.connectivityList = data.ConnectivityList;
            obj.numOfElements = height(obj.connectivityList);
            obj.points = data.Points;
            obj.sliceThickness = preferedThickness;
        end
        
        % Gets the X, Y, Z Coordinates of the slice path
        function slicePath = getSlicePath(obj)
            slicePath = obj.slicePath;
        end
        
        % Inspect each element and get sliced nodes (if applicable)
        
        % Inspect a line between two nodes and evaluate if a point exists
        function points = getSlicePoint(obj, point1, point2, currZ)
        % Generates a point for a given line between two points
            
            % Create Null Array
            points = zeros(0);
        
            % Parse the Point Data
            x1 = point1(1,1);
            y1 = point1(1,2);
            z1 = point1(1,3);
            x2 = point2(1,1);
            y2 = point2(1,2);
            z2 = point2(1,3);
            
            % If the line cuts through the slice, then find the point
            if ((z1 <= currZ && currZ <= z2) || (currZ <= z1 && z2 <= currZ))
                
                % If the line sits on the plane, add both end coordinates
                if (z1 == z2)
                    points = [points; x1, y1, z1];
                    points = [points; x2, y2, z2];
            
                % Otherwise, if not horizontal, determine the cut point
                else
                    X = x1 + ((z1-currZ)/(z1-z2))*(x2-x1);
                    Y = y1 + ((z1-currZ)/(z1-z2))*(y2-y1);
                    Z = currZ;
                    points = [points; X, Y, Z];
                end

            end
            
        end
        
        % Obtain the X,Y,Z Coordinate for each node of an element object
        function elementData = getElementData(obj, elementNumber)
        
            % Lookup Element in Connectivity List and obtain node numbers
            if (elementNumber > obj.numOfElements || elementNumber < 1)
                throw Exception("Invalid Element Number");
            end
            nodes = obj.connectivityList(elementNumber,:);
            
            % Compound the nodes into a nxn matrix and return
            numNodes = length(nodes);
            elementData = zeros(length(nodes));
            for i = 1:numNodes
                elementData(i,:) = obj.points(nodes(1,i), :);
            end
            
        end
        
        
        
        
        
        
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
    
    methods (Access = protected)
        
    end
    
end

