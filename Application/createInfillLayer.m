function [infillPath] = createInfillLayer(sliceGen,infillDistance)
warning('off','all')
%     clear all

%     fileLocation = "Test Objects/AdaptiveSlicingFigureA.STL";

    % Inputs
%     stl = stlread(fileLocation);
%     stl = stlTransform(stl, 90, 0, 0, 0, 0, 0, 100);

%     sliceHeight = 0.2;
    % sliceGen = FlatUniformSliceGenerator(stl,sliceHeight);
%     sliceGen = FlatAdaptiveSliceGenerator(stl,sliceHeight);
    % layer = 16.8;

    % Set infill Distance
%     infillDistance = 2;

    slicePath = sliceGen.getSlicePath;
    infillPath = [];
    [C,~,~]=unique(slicePath(:,3));
    
    for j =1:height(C)
        % This will be handled by Module 2 GUI

        layerPath = sliceGen.slicePathLayer(C(j));
%         layerPath = sliceGen.slicePathLayer(14);

        % Find minimum x and y values of layer path to set template of infill.
        minX = min(layerPath(:,1));
        maxX = max(layerPath(:,1));
        minY = min(layerPath(:,2));
        maxY = max(layerPath(:,2));

        % Set polygon of layer
        %     layerPolygon =  polyshape( layerPath(  : , 1 ),layerPath( :,2));
        numOfparts = max(layerPath(:,4));

        polyLayerPath = [];
        for i = 1: numOfparts
            temp = find(ismember(layerPath(:,4),i,'rows'));
            
%             partNum = i;
            
            zHeight = layerPath(1,3);

            x = layerPath(  min(temp):max(temp) , 1 );
            y = layerPath( min(temp):max(temp),2);
            polyHeight = height(polyLayerPath);
            if isempty(polyLayerPath)
                polyLayerPath(:,1) = x;
                polyLayerPath(:,2) = y;
                polyLayerPath(:,3) = zHeight;
%                 polyLayerPath(:,4) = partNum;
            else
                polyLayerPath(polyHeight+1:polyHeight+height(x) , 1) = x;
                polyLayerPath(polyHeight+1:polyHeight+height(y) , 2) = y;
                polyLayerPath(polyHeight+1:polyHeight+height(zHeight) , 3) = zHeight;
                
%                 polyLayerPath(polyHeight+1:polyHeight+height(x) , 4) = partNum;
            end 
        polyLayerPath(height(polyLayerPath)+1,1:3) = NaN;
        end
        
                % Create Polygon Shape
        layerPolygon = polyshape(polyLayerPath(:,1),polyLayerPath(:,2));

        % Find all the points from min X to max X with incriment of infill
        % distance.
        res = linspace(minX,maxX,(maxX-minX)/infillDistance);
        res = transpose(res);

        % Pass back into a variable where intersect can understand.
        minLineseg = zeros(height(res),1);
        minLineseg(:,1) = minY;
        maxLineseg = zeros(height(res),1);
        maxLineseg(:,1) = maxY;

        % Initialize Path Array 
        %NVM I realised I wont know how many intersects it can be. :(

        flip = 1;
        % plot(layerPolygon);
%         infillPartNum = 1;
        for i=1:height(res)
            % Create current line to cut the shape.
            lineseg = [res(i,:) minLineseg(1,1); res(i,:) maxLineseg(1,1)];

            
            [in,out] = intersect(layerPolygon,lineseg);
            
            tempHeight = height(infillPath);
            % Append to 'in' to new array 'infillpath'
            if height(infillPath) == 0 && ~isempty(in)
                infillPath = in;
            elseif ~isempty(in)
%                 infillPath(tempHeight+1,:) = infillPath(tempHeight,1:4);
                % Flip flop to alternate to draw lines bottom and top.
                if flip ==1
                    infillPath(tempHeight+1:(tempHeight)+height(in),1:2) = flipud(in(:,1:2));
                    flip = 2;
                else
                    infillPath(tempHeight+1:(tempHeight)+height(in),1:2) = in(:,1:2);
                    flip = 1;
                end
                
        
            else
                % Handles if there's a gap in the x axis.
                infillPath(height(infillPath)+1,:) = NaN;

            end
            infillPath(tempHeight+1:tempHeight+height(in),3) = zHeight;
       
        end

    end 
    [row,~] = find(isnan(infillPath));
    infillPath(:,4) = 1;
    infillPath(row,1:4) = NaN;
    
    
    % Im sorry daniel post processing is the only way I could think of :(
    % find each z layer from slice gen.
    zThickness = sliceGen.sliceThickness;
    for i = 0:zThickness:max(infillPath(:,3))
        % Index of current z axis.
        zIndex = find(ismember(infillPath(:,3),i));
        
        % Go through the z axis and check for NaN in x y axis, if NaN next ones
        % increase part num by 1.
        nanIndex = find(isnan(infillPath(min(zIndex):max(zIndex),4)))+(min(zIndex)-1);
        if ~isempty(nanIndex)
            if (height(nanIndex) == 1)
                infillPath(nanIndex:max(zIndex),4) = infillPath(nanIndex:max(zIndex),4) + 1;
            else
                tempCounter = 1;
                for j = 1: height(nanIndex)-1
                    infillPath(nanIndex(j,:):nanIndex(j+1,:),4)= infillPath(nanIndex(j,:):nanIndex(j+1,:),4)+(j);
                    tempCounter = j;
                end
                
                if (j == height(nanIndex)-1)
                infillPath(nanIndex(tempCounter+1):max(zIndex),4) = infillPath(nanIndex(tempCounter+1):max(zIndex),4) + (tempCounter+1);
                end
            end
        end
        
    end
    
    % Clean NaN so export doesn't have it.
    infillPath = nanCleanUp(infillPath);
    
    
end




