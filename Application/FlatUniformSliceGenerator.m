%   Flat Uniform Slice Generator (FlatUniformSliceGenerator.m)
%   Uses Original Code to generate equations for Slices at Uniform
%   Thickness

classdef FlatUniformSliceGenerator < handle
    
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
        
        % Generates and stores all slices
        function obj = generateSlices(obj)
        
            % Get the maximum Z height
            maxZ = max(obj.points(:, 3));
            currZ = 0;
            
            % Slice at each layer height
            while currZ < maxZ
                
                % Slice at this layer and append to slice Path
                obj.slicePath = [obj.slicePath; slice(obj, currZ)];
                currZ = currZ + obj.sliceThickness;
                
            end
            
            % If the end is reached, add the final layer
            obj.slicePath = [obj.slicePath; slice(obj, maxZ)];
            
            obj.slicePath
                
        end
        
        
        % Inspect each slice and determine elements which are cut
        function points = slice(obj, zHeight)
        
            promisedPairs = zeros(0);
            
            % Slice each node at this height
            for element = 1:obj.numOfElements
                
                promisedPairs = [promisedPairs; sliceElement(obj, element, zHeight)];
                
            end
            
            promisedPairs;
            shape = alphaShape([promisedPairs(:,1); promisedPairs(:,4)], [promisedPairs(:,2); promisedPairs(:,5)]);
            plot(shape)
            points = sortPromisedPairsToPath(obj, promisedPairs);
            points;
            
        end
        
        %% RECUSRSION
        function path = sortPromisedPairsToPath(obj, promisedPairs)
        
            numPromisePairs = height(promisedPairs);
            
            if numPromisePairs == 0
                return
            end
            
            if numPromisePairs == 1
                path = [promisedPairs(1, 1:3); promisedPairs(1, 4:6)];
                return
            end
            
            % Remove Duplicate Paths
            [~,uPP] = unique(promisedPairs , 'rows');
            promisedPairs = promisedPairs(uPP,:);
            
            % Remove Dupliate Paths in flipped array
            promisedPairsFlipped = [promisedPairs(:,4:6), promisedPairs(:,1:3)];
            [~,a,b] = intersect(promisedPairs,promisedPairsFlipped,'rows');
            removed = setxor(b,a);
            promisedPairs(removed',:) = [];

            
            % Start with original point
            path = [promisedPairs(1, 1:3); promisedPairs(1, 4:6)];
            
            % Remove first point and sort remaining promises
            promisedPairs(1,:) = [];
            
            % Sort the remainder
            path = [path; sortPromisedPairsToPathRecursion(obj, promisedPairs, path)];
            
        end
        
        function returnPath = sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, currentPath)
            
            % If the remaining pairs in subset is 1, just return the
            % current pair
            if height(remainingPromisedPairs) == 1
                returnPath = [remainingPromisedPairs(1, 1:3); remainingPromisedPairs(1, 4:6)];
            
            % Otherwise, sort the remainder
            else
                
                % Find the next point which matches the current end of path
                xE = currentPath(end, 1); xS = currentPath(1, 1);
                yE = currentPath(end, 2); yS = currentPath(1, 2);
                
                for i = 1:height(remainingPromisedPairs)
                
                    x = remainingPromisedPairs(i, 1);
                    y = remainingPromisedPairs(i, 2);
                    
                    % If this is a match, then append
                    if (xE == x && yE == y)
                       
                        returnPath = [remainingPromisedPairs(i, 1:3); remainingPromisedPairs(i, 4:6)];
                        remainingPromisedPairs(i,:) = [];
                        
                        returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath])];
                        
                        return
                        
                    end
                    
                    % If this is a match, then append
                    if (xS == x && yS == y)
                       
                        returnPath = [remainingPromisedPairs(i, 1:3); remainingPromisedPairs(i, 4:6)];
                        remainingPromisedPairs(i,:) = [];
                        
                        returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath])];
                        
                        return
                        
                    end
                    
                    x = remainingPromisedPairs(i, 4);
                    y = remainingPromisedPairs(i, 5);
                    
                     % If this is a match, then append
                    if (xE == x && yE == y)
                       
                        returnPath = [remainingPromisedPairs(i, 4:6); remainingPromisedPairs(i, 1:3)];
                        remainingPromisedPairs(i,:) = [];
                        
                        returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath])];
                        
                        return
                        
                    end
                    
                     % If this is a match, then append
                    if (xS == x && yS == y)
                       
                        returnPath = [remainingPromisedPairs(i, 4:6); remainingPromisedPairs(i, 1:3)];
                        remainingPromisedPairs(i,:) = [];
                        
                        returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath])];
                        
                        return
                        
                    end
                    
                end
                
                returnPath = zeros(0);
                
                
            end
            
        end
        
        % Inspect each element and get a promised pair (path between two
        % nodes along the profile of the element
        function promisedPairs = sliceElement(obj, elementNumber, zHeight)
            
            % Initalise the matrices
            promisedPairs = zeros(0);
            promisedPoints = zeros(0);
            
            % Parse the data for this element
            elementVertices = getElementData(obj, elementNumber);
            numOfVertices = height(elementVertices);
            
            % For each element, generate points for each edge of shape
            for edge = 1: numOfVertices - 1
                
                point1 = elementVertices(edge, :);
                point2 = elementVertices(edge + 1, :);
                points = getSlicePoint(obj, point1, point2, zHeight);
                
                % If two points, hold this pair and append
                if height(points) == 2
                    promisedPairs = [promisedPairs; points(1,:), points(2,:)];
                else
                    % If point already exists, ignore
                    promisedPoints = [promisedPoints; points];
                end
                
            end
            
            % Complete Final Point
            point1 = elementVertices(numOfVertices, :);
            point2 = elementVertices(1, :);
            points = getSlicePoint(obj, point1, point2, zHeight);
            
            % If two points, hold this pair and append
            if height(points) == 2
                promisedPairs = [points(1,:), points(2,:)];
            else
                promisedPoints = [promisedPoints; points];
            end
                
            % If there are two points held, then append to PromisedPairs
            if height(promisedPoints) > 1
                promisedPairs = [promisedPairs;  promisedPoints(1,:), promisedPoints(2,:)];
            end            
            
            % Plot
%             if (height(promisedPoints) > 0)
%                 plot3(promisedPoints(:,1), promisedPoints(:,2), promisedPoints(:,3),'-r*','LineWidth',2);
%             end
%             x = 0;
            
            
            
        end
        
        % Inspect a line between two nodes and evaluate if a point exists
        function promisedPoints = getSlicePoint(obj, point1, point2, currZ)
        % Generates a point for a given line between two points
            
            % Create Null Array
            promisedPoints = zeros(0);
        
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
                    promisedPoints = [promisedPoints; x1, y1, currZ; x2, y2, currZ];      
                % Otherwise, if not horizontal, determine the cut point
                else
                    X = x1 + ((z1-currZ)/(z1-z2))*(x2-x1);
                    Y = y1 + ((z1-currZ)/(z1-z2))*(y2-y1);
                    Z = currZ;
                    promisedPoints = [promisedPoints; X, Y, Z];
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
    
    
end

