%   Flat Uniform Slice Generator (FlatUniformSliceGenerator.m)
%   Uses Original Code to generate equations for Slices at Uniform
%   Thickness.

classdef FlatUniformSliceGenerator < handle
    
    properties (SetAccess = protected)
        
        % Reference to this object
        obj;
        
        % The Connectivity List defining the nodes of each Element, and the
        % points which represent the coordinate of each node.
        connectivityList(:,:) double
        numOfElements int64
        points(:,:) double
        
        % The Uniform Slice Thickness for each slice - default is 0.2
        sliceThickness = 0.2;
        
        % Stores the slicer path points for this object
        slicePath = [];
        
        % Accuracy of slicer
        slicerTol = 1e-5;
        
    end
    
    methods (Access = public)
        
        % Create an instance using Triangulation Data
        function obj = FlatUniformSliceGenerator(data, preferedThickness)
            obj.connectivityList = data.ConnectivityList;
            obj.numOfElements = height(obj.connectivityList);
            obj.points = data.Points;
            obj.sliceThickness = preferedThickness;
        end
        
        % Slice and return the X, Y, Z Coordinates of the slice path
        function slicePath = getSlicePath(obj)
            generateSlicePath(obj);
            slicePath = obj.slicePath;
        end
        
        % Inspect each slice and determine elements which are cut
        function points = slicePathLayer(obj, zHeight)
        
            % Instantiate Objects to store Points and Paths
            slicePaths = zeros(0);
            specialPoints = zeros(0);
            points = zeros(0);
            
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
            % However, some repeated paths or point data may exist. Filter 
            % and then tesslate paths together.
            
            % Remove paths which start and end at the same point
            rowsToRemove = [];
            for i=1:height(slicePaths)
               
                if slicePaths(i,1) == slicePaths(i,4) && slicePaths(i,2) == slicePaths(i,5) && slicePaths(i,3) == slicePaths(i,6)
                    rowsToRemove = [rowsToRemove; i];
                end

            end
            slicePaths(rowsToRemove,:) = [];
            
            % Now, remove duplicate paths
            % Firstly, store all the unique paths & delete from slicePaths
            [uniqueSlicePaths, uniqueSlicePathIndexes, ~] = unique(slicePaths, 'rows');
            slicePaths(uniqueSlicePathIndexes,:) = [];

            % For the remaining duplicates, add one copy to the unique
            % paths
            singleInstanceSlicePath = [];
            for i = 1:height(slicePaths)
                if ~ismember(singleInstanceSlicePath, slicePaths(i,:))
                    singleInstanceSlicePath = slicePaths(i,:);
                end
            end

            %Restore all the unique paths to the slicePaths
            slicePaths = [uniqueSlicePaths; singleInstanceSlicePath];
                
            % Create paths - continues to loop for each continuous path
            % until all paths have been generated.
            currentPath = 0;
            while (height(slicePaths) > 0)
                currentPath = currentPath + 1;
                [resultingPath, slicePaths] = sortPromisedPairsToPath(obj, slicePaths, currentPath);
                points = [points; resultingPath];
            end
            
        end
          
    end
    
    methods (Access = protected)
        
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
        
        function obj = generateSlicePath(obj)
        % Generate the full slice path for all layers of this object
            
            % Generate the slice heights
            sliceHeights = obj.generateSliceHeights();
            
            % Iterate and generate the slices paths for each layer
            for zHeightIndex = 1:height(sliceHeights)
                currZ = sliceHeights(zHeightIndex);
                dSlice = slicePathLayer(obj, currZ);
                obj.slicePath = [obj.slicePath; dSlice];
            end
        
        end
        
        function [path, slicePaths] = sortPromisedPairsToPath(obj, slicePaths, currentPathNumber)
        % Function which orders the individual paths from the slicers in a
        % form which can generate a single continuous path for the
        % machine to follow. Will return the remaining slice paths which
        % could not be stiched for this single path.
        
            % Get the total number of individual paths
            numPromisePairs = height(slicePaths);
            
            % If there are none, return the empty slice paths as-is
            if numPromisePairs == 0
                return
            
            % If there is only one pair, then return the single pair
            elseif numPromisePairs == 1
                path = [slicePaths(1, 1:3), currentPathNumber; slicePaths(1, 4:6), currentPathNumber];
                slicePaths(1,:) = [];
                return
            end

            % Start with original point
            path = [slicePaths(1, 1:3), currentPathNumber]; %; promisedPairs(1, 4:6)];
            
            % Sort the remainder
            [resultingPath, slicePaths] = sortPromisedPairsToPathRecursion(obj, slicePaths, path, currentPathNumber);
            path = resultingPath;
            path = [path; path(1,:)];
            
        end
        
        function [resultingPath, remainingPaths] = sortPromisedPairsToPathRecursion(obj, remainingPaths, resultingPath, currentPathNumber)
        % The recursive method which assembles a continuous path using all the paths
        % generated from slicing. If multiple paths exist, this function
        % will return the remaining paths left over from each path
        % generated until all paths are created.
            
            % Define
            returnPath = zeros(0);
            
            % If the remaining pairs in subset is 1, there is only one more
            % line - add and return the resultingPath
            if height(remainingPaths) == 1
               
                % If start of final line if at end, append
                if (abs(resultingPath(end,1) - remainingPaths(end,1)) < obj.slicerTol && abs(resultingPath(end,2) - remainingPaths(end,2)) < obj.slicerTol)
                    returnPath = [remainingPaths(1, 4:6), currentPathNumber];
   
                % Otherwise, return opposite end
                else
                    returnPath = [remainingPaths(1, 1:3), currentPathNumber];
                end
                
                % Finally, clear the remainingPaths
                remainingPaths(1,:) = [];
            
            % Otherwise, sort the remainingPaths via recursion
            else
                
                % Get the current start and end point of the path
                % generated thus far
                xE = resultingPath(end, 1); xS = resultingPath(1, 1);
                yE = resultingPath(end, 2); yS = resultingPath(1, 2);
                
                % If the start and end of the path is the same, then return
                % this path - it is completed
                if (height(resultingPath) > 1) && (xE == xS) && (yE == yS)
                    return
                end
                
                % Iterate through all remainingPaths not yet assembled to
                % find next path to stich to the resultingPath
                for i = 1:height(remainingPaths)
                
                    % First, check for the start coordinates of this path (line)                    
                    x = remainingPaths(i, 1);
                    y = remainingPaths(i, 2);
                    
                    % If the end of the returnPath matches the start of
                    % this line, then append the end point of this line to
                    % the path and remove from remainingPaths
                    if (abs(xE - x) < obj.slicerTol && abs(yE - y) < obj.slicerTol)
                        returnPath = [remainingPaths(i, 4:6), currentPathNumber];
                        remainingPaths(i,:) = [];
                        resultingPath = [resultingPath; returnPath];
                        [resultingPath, remainingPaths] = sortPromisedPairsToPathRecursion(obj, remainingPaths, resultingPath, currentPathNumber);
                        return
                    end
                    
                    % If the start of the returnPath matches the start of
                    % this line, then flip the lines direction and append
                    % the end to the beginning of the returnPath
                    if (abs(xS - x) < obj.slicerTol && abs(yS - y) < obj.slicerTol)
                        returnPath = [remainingPaths(i, 4:6), currentPathNumber];
                        remainingPaths(i,:) = [];
                        resultingPath = [returnPath; resultingPath];
                        [resultingPath, remainingPaths] = sortPromisedPairsToPathRecursion(obj, remainingPaths, resultingPath, currentPathNumber);
                        return 
                    end
                    
                    % Now, check for the end coordinates of this line
                    x = remainingPaths(i, 4);
                    y = remainingPaths(i, 5);
                    
                    % If the end of the returnPath matches the end of
                    % this line, then flip the lines direction and 
                    % append the start to the path
                    if (abs(xE - x) < obj.slicerTol && abs(yE - y) < obj.slicerTol) %(xE == x && yE == y)
                        returnPath = [remainingPaths(i, 1:3), currentPathNumber];
                        remainingPaths(i,:) = [];
                        resultingPath = [resultingPath; returnPath];
                        [resultingPath, remainingPaths] = sortPromisedPairsToPathRecursion(obj, remainingPaths, resultingPath, currentPathNumber);
                        return  
                    end
                    
                    % If the start of the returnPath matches the end of
                    % this line, then append the start to the beginning 
                    % of the returnpath
                    if (abs(xS - x) < obj.slicerTol && abs(yS - y) < obj.slicerTol) %(xS == x && yS == y)
                        returnPath = [remainingPaths(i, 1:3), currentPathNumber];
                        remainingPaths(i,:) = [];
                        resultingPath = [returnPath; resultingPath];
                        [resultingPath, remainingPaths] = sortPromisedPairsToPathRecursion(obj, remainingPaths, resultingPath, currentPathNumber);
                        return
                    end
                    
                end
                
            end
            
        end
        
        function paths = sliceElement(obj, elementNumber, zHeight)
        % Inspect each element and all the point(s) which are sliced along
        % this z position
        
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
                    
                    % If the item already exists, however, ignore (when
                    % slicing through point
                    if (height(intersectingPoints) == 0 || ~(ismember(slicedPoints(1,:), intersectingPoints, 'rows')))
                        intersectingPoints = [intersectingPoints; slicedPoints(1,:)];
                    end
                    
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
                paths = [intersectingPoints, intersectingPoints];
            end
            
            % Otherwise, there is just a single path touching the plane -
            % return existing values
                 
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
        
        function elementData = getElementData(obj, elementNumber)
        % Obtain the X,Y,Z Coordinate for each node of an element on the
        % object
        
            % Lookup Element in Connectivity List and obtain node numbers
            if (elementNumber > obj.numOfElements || elementNumber < 1)
                throw Exception("Invalid Element Number");
            end
            
            % Get the number of nodes for this element
            nodes = obj.connectivityList(elementNumber,:);
            
            % Compound the nodes into a nxn matrix and return
            numNodes = length(nodes);
            elementData = zeros(length(nodes));
            for i = 1:numNodes
                elementData(i,:) = obj.points(nodes(1,i), :);
            end
            
        end
        
    end
    
end

