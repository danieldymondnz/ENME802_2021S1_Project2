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
        
        % Accuracy of slicer
        slicerAccuracy = 0.01;
        slicerTol;
        
    end
    
    methods
        
        % Create an instance using Triangulation Data
        function obj = FlatUniformSliceGenerator(data, preferedThickness)
            obj.connectivityList = data.ConnectivityList;
            obj.numOfElements = height(obj.connectivityList);
            obj.points = data.Points;
            obj.sliceThickness = preferedThickness;
            obj.slicerTol = 0.01;
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
        
            slicePaths = zeros(0);
            specialPoints = zeros(0);
            
            % Slice each element and inspect
            for element = 1:obj.numOfElements
                
                % Get the path(s) or point for an element
                elementPaths = sliceElement(obj, element, zHeight);
                
                % If this element only has a single touching point, append
                % to 'specialPoints'
                if (height(elementPaths) == 1 && width(elementPaths) == 3)
                    specialPoints = [specialPoints; elementPaths];
                
                % Otherwise, store the slicePaths of interest for this element
                else
                    slicePaths = [slicePaths; elementPaths];
                end

            end
            
            % With all elements checked on this plane, check results
            
            % If only one point is on the plane, than keep this as the
            % point for this plane and return
            if (height(slicePaths) == 0 && height(specialPoints) == 1)
                slicePaths = [specialPoints, specialPoints];
                return;
            end
            
            % Otherwise, if paths exist, the special points can be ignored.
            % However, some repeated paths may exist. Tesselate Paths
            % together.
            
            
            slicePaths;
            points = sortPromisedPairsToPath(obj, slicePaths);
            points;
            
        end
        
        
        
            
        
        % RECUSRSION TO CLEAN
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
%             [~,a,b] = intersect(promisedPairs(:,1:3),promisedPairs(:,4:6),'rows');
%             removed = setxor(b,a);
%             promisedPairs(removed',:) = [];
            
%             [~,uPP] = unique(promisedPairs , 'rows');
%             promisedPairs = promisedPairs(uPP,:);
            
            % Remove Dupliate Paths in flipped array
            promisedPairsFlipped = [promisedPairs(:,4:6), promisedPairs(:,1:3)];
            [~,a,b] = intersect(promisedPairs,promisedPairsFlipped,'rows');
            removed = setxor(b,a);
            promisedPairs(removed',:) = [];

            % Start with original point
            path = [promisedPairs(1, 1:3)]; %; promisedPairs(1, 4:6)];
            
            % Remove first point and sort remaining promises
            %promisedPairs(1,:) = [];
            
            % Sort the remainder
            pathSort = sortPromisedPairsToPathRecursion(obj, promisedPairs, path);
            path = [pathSort];
            path = [path; path(1,:)];
        end
        
        function currentPath = sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, currentPath)
            
            % Deifne
            returnPath = zeros(0);
            
            % If the remaining pairs in subset is 1, connect line
            if height(remainingPromisedPairs) == 1
               
                % If start of final line if at end, append
                if (abs(currentPath(end,1) - remainingPromisedPairs(end,1)) < obj.slicerTol && abs(currentPath(end,2) - remainingPromisedPairs(end,2)) < obj.slicerTol)
                    returnPath = remainingPromisedPairs(1, 4:6);
                    
                % Otherwise, return opposite end
                else
                    returnPath = remainingPromisedPairs(1, 1:3);
                end
                
                % Otherwise, flip line

                %returnPath = [remainingPromisedPairs(1, 1:3); remainingPromisedPairs(1, 4:6)];
            
            % Otherwise, sort the remainder
            else
                
                % Find the next point which matches the current end of path
                xE = currentPath(end, 1); xS = currentPath(1, 1);
                yE = currentPath(end, 2); yS = currentPath(1, 2);
                
                for i = 1:height(remainingPromisedPairs)
                
                    % Check the start coordinates of this line                    
                    x = remainingPromisedPairs(i, 1);
                    y = remainingPromisedPairs(i, 2);
                    
                    % If the end of the returnPath matches the start of
                    % this line, then append the end point of this line to
                    % the path
                    if (abs(xE - x) < obj.slicerTol && abs(yE - y) < obj.slicerTol) %(xE == x && yE == y)
                        returnPath = remainingPromisedPairs(i, 4:6);
                        remainingPromisedPairs(i,:) = [];
                        %returnPath = [sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath]); returnPath];
                        
                        currentPath = [currentPath; returnPath];
                        currentPath = sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, currentPath);
                        return
                    end
                    
                    % If the start of the returnPath matches the start of
                    % this line, then flip the lines direction and append
                    % the end to the beginning of the returnpath
                    if (abs(xS - x) < obj.slicerTol && abs(yS - y) < obj.slicerTol) %(xS == x && yS == y)
                        returnPath = remainingPromisedPairs(i, 4:6);
                        remainingPromisedPairs(i,:) = [];
%                         returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [returnPath; currentPath]);];
                        currentPath = [returnPath; currentPath];
                        currentPath = sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, currentPath);
                        return 
                    end
                    
                    % Check the end coordinates of this line
                    x = remainingPromisedPairs(i, 4);
                    y = remainingPromisedPairs(i, 5);
                    
                    % If the end of the returnPath matches the end of
                    % this line, then flip the lines direction and 
                    % append the start to the path
                    if (abs(xE - x) < obj.slicerTol && abs(yE - y) < obj.slicerTol) %(xE == x && yE == y)
                        returnPath = remainingPromisedPairs(i, 1:3);
                        remainingPromisedPairs(i,:) = [];
                        %returnPath = [sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath]); returnPath];
                        currentPath = [currentPath; returnPath];
                        currentPath = sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, currentPath);
                        return  
                    end
                    
                    % If the start of the returnPath matches the end of
                    % this line, then append the start to the beginning 
                    % of the returnpath
                    if (abs(xS - x) < obj.slicerTol && abs(yS - y) < obj.slicerTol) %(xS == x && yS == y)
                        % backup
%                         returnPath = [remainingPromisedPairs(i, 4:6); remainingPromisedPairs(i, 1:3)];
%                         remainingPromisedPairs(i,:) = [];
%                         returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [currentPath; returnPath])];
                        
                        returnPath = remainingPromisedPairs(i, 1:3);
                        remainingPromisedPairs(i,:) = [];
                        %returnPath = [returnPath; sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, [returnPath; currentPath])];
                        
                        currentPath = [returnPath; currentPath];
                        currentPath = sortPromisedPairsToPathRecursion(obj, remainingPromisedPairs, currentPath);
                        
                        return
                        
                    end
                    
                end
                
                % Wrap the return path such that more elements can be
                % appended
                for i = 1:height(returnPath)
                   
                    % If works, then 
                    
                end
                
                % If not possible, create new recursion
                
                returnPath = zeros(0);
                
                
            end
            
        end
        
        
        
        
        % Inspect each element and get a promised pair (path between two
        % nodes along the profile of the element
        function paths = sliceElement(obj, elementNumber, zHeight)
            
            % Initalise the matrices
            paths = zeros(0);
            intersectingPoints = zeros(0);
            
            % Parse the data for this element
            elementVertices = getElementData(obj, elementNumber);
            numOfVertices = height(elementVertices);
            
            % For each edge of the element, check to see if edge has
            % intersect or not.
            for edge = 1: numOfVertices
                
                pN1 = edge;
                pN2 = edge + 1;
                
                if pN2 > numOfVertices
                    pN2 = 1;
                end
                
                point1 = elementVertices(pN1, :);
                point2 = elementVertices(pN2, :);
                slicedPoints = getSlicePoint(obj, point1, point2, zHeight);
                
                % If two points are returned, this edge lies on the plane.
                % Append to lines
                if height(slicedPoints) == 2
                    paths = [paths; slicedPoints(1,:), slicedPoints(2,:)];
                    
                % If only a single point is returned, hold this item -
                % either this is a triangle with two intercepting edges or
                % 1 vertice touching the plane
                elseif height(slicedPoints) == 1
                    intersectingPoints = [intersectingPoints; slicedPoints(1,:)];
                end
                % Otherwise, nothing is found on this edge - proceed to
                % next
                                    
            end
            
            % With all edges checked, now review the geometry of this
            % element
            
            % If all edges are touching the plane, than this geometry is
            % not relevant to the overall path - return nothing
            if height(paths) == 3
                paths = zeros(0);
            
            % If there are two intersectingPoints, the line between these
            % points will generate a path for this layer
            elseif height(intersectingPoints) == 2 
                paths = [intersectingPoints(1,:), intersectingPoints(2,:)];
            
            % If there is only one intersectingPoint stored, this is the
            % only touching element on this plane - return for analysis
            elseif height(intersectingPoints) == 1
                paths = [intersectingPoints, interestingPoints];
            end
            
            % Otherwise, there is just a single path touching the plane -
            % return existing values
            paths;
                 
        end
        
        function intersectingVertices = getSlicePoint(obj, point1, point2, currZ)
        % Inspect a line between two vetrices and evaluate if a point exists
        
            % Define blank object
            intersectingVertices = zeros(0);
        
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
                    intersectingVertices = [x1, y1, currZ; x2, y2, currZ];      
                    
                % Otherwise, if not horizontal, determine the cut point
                else
                    X = x1 + ((z1-currZ)/(z1-z2))*(x2-x1);
                    Y = y1 + ((z1-currZ)/(z1-z2))*(y2-y1);
                    Z = currZ;
                    intersectingVertices = [X, Y, Z];
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

