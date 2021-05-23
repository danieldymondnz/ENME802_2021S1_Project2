function pathsWithInfill = FlatSliceInfillGenerator(pathsToInfill,percentage)
% Flat Slice Infill Generator
% Generates the infill based upon a number of flat sliced paths genreated
% by a FlatSliceGenerator Object

    pathsWithInfill = zeros(0);

    % Determine the z heights at which the flat slices reside at
    [~, zHeights] = groupcounts(pathsToInfill(:,3));
    
    % For each, perform the infill generation
    for i = 1:height(zHeights)
       
        % Get all the paths at this level
        layerToInfill = pathsToInfill(pathsToInfill(:,3) == zHeights(i), :);
        
        % Run a Function Here
        infilledLayer = layerToInfill;
        
        % Return paths with infill added
        pathsWithInfill = [pathsWithInfill; infilledLayer];
        
    end

end