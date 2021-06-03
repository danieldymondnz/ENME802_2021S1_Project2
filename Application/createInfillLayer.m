function [infillPath] = createInfillLayer(sliceGen,infillDistance)
warning('off','all')


    slicePath = sliceGen.getSlicePath;
    infillPath = [];
    [C,~,~]=unique(slicePath(:,3));
    
    for j =1:height(C)
       
        % Find all layerpaths for each height
        layerPath = slicePath(slicePath(:,3) == C(j),:);


        % Find minimum x and y values of layer path to set template of infill.
        minX = min(layerPath(:,1));
        maxX = max(layerPath(:,1));
        minY = min(layerPath(:,2));
        maxY = max(layerPath(:,2));

        % Set polygon of layer
        numOfparts = max(layerPath(:,4));

        % Separate polygon shapes by parts and redraw them later
        polyLayerPath = [];
        for i = 1: numOfparts
            temp = find(ismember(layerPath(:,4),i,'rows'));
            
            
            zHeight = layerPath(1,3);

            x = layerPath(  min(temp):max(temp) , 1 );
            y = layerPath( min(temp):max(temp),2);
            polyHeight = height(polyLayerPath);
            if isempty(polyLayerPath)
                polyLayerPath(:,1) = x;
                polyLayerPath(:,2) = y;
                polyLayerPath(:,3) = zHeight;
            else
                polyLayerPath(polyHeight+1:polyHeight+height(x) , 1) = x;
                polyLayerPath(polyHeight+1:polyHeight+height(y) , 2) = y;
                polyLayerPath(polyHeight+1:polyHeight+height(zHeight) , 3) = zHeight;

            end 
        polyLayerPath(height(polyLayerPath)+1,1:3) = NaN;
        end
        
        % Create Polygon Shape
        layerPolygon = polyshape(polyLayerPath(:,1),polyLayerPath(:,2));

        % Find all the points from min X to max X with incriment of infill
        % distance.
        res = linspace(minX,maxX,(maxX-minX)/infillDistance)-1;
        res = transpose(res);

        % Pass back into a variable where intersect can understand.
        minLineseg = zeros(height(res),1);
        minLineseg(:,1) = minY;
        maxLineseg = zeros(height(res),1);
        maxLineseg(:,1) = maxY;

        % Initialise flip so it always starts at 1
        flip = 1;

        for i=1:height(res)
            % Create current line to cut the shape.
            lineseg = [res(i,:) minLineseg(1,1); res(i,:) maxLineseg(1,1)];

            
            [in,~] = intersect(layerPolygon,lineseg);
            
            tempHeight = height(infillPath);
            % Append to 'in' to new array 'infillpath'
            if height(infillPath) == 0 && ~isempty(in)
                infillPath = in;
            elseif ~isempty(in)
%                 infillPath(tempHeight+1,:) = infillPath(tempHeight,1:4);         
                tempHeight = height(infillPath);
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
                infillPath(tempHeight+1,1:2) = NaN;
                infillPath(tempHeight+1,3) = zHeight;


            end
            infillPath(tempHeight+1:tempHeight+height(in),3) = zHeight;

        end

    end 
    
    % Make rows equal to NaN if there is already a NaN 
    % and initialize part numbers as 1 for now.
    [row,~] = find(isnan(infillPath));
    infillPath(:,4) = 1;
    infillPath(row,1:2) = NaN;
    
    % Just to save memory :)
    clear row;
    clear res;
    clear slicePath;
    clear C;
   
    % find each z layer
    zThicknesses = unique(infillPath(:,3));
    % initialize variable as an array
    newInfillPath = [];
    % Loop through each layer height
    for i = 1:height(zThicknesses)
        % Reset part number counter every layer
        tempCounter = 1;
        currentZ = zThicknesses(i);
        % Find where all the paths for current layer
        temp = infillPath(infillPath(:,3) == currentZ,:);
        % Find all the NaNs to reference where it should increment part num
        nanIndex = find(isnan(temp(:,2)));
        
        % If code found somewhere where there is NaN, increment part number
        % by 1 to make sure GUI draws separately.
        if ~isempty(nanIndex)
            if height(nanIndex) ==1
                temp(nanIndex:height(temp),4) = temp(nanIndex:height(temp),4) + tempCounter;
            
            else
                % Loop through all of the NaN indexes and increment the
                % part numbers in between 2 NaN's by 1
                for j = 1: height(nanIndex)-1
                    temp(nanIndex(j,:):nanIndex(j+1),4) = temp(nanIndex(j,:):nanIndex(j+1),4) + tempCounter;
                    tempCounter = tempCounter + 1;
                    
                    % Increment all of the last part numbers from last NaN by 1
                    if j == (height(nanIndex)-1)
                        temp(nanIndex(height(nanIndex)):height(temp),4) = temp(nanIndex(height(nanIndex)):height(temp),4) + tempCounter;
                    end
                end
                
                
            end
            
            
        end
        
        
        % Append back into new array.
        newInfillPath(height(newInfillPath)+1:height(newInfillPath)+height(temp),:) = temp;
        
    end
    clear temp;
    clear infillPath;
    % Clean NaN so export doesn't have it.
    
    [row,~] = find(isnan(newInfillPath));
    newInfillPath(row,1:4) = NaN;
    
    infillPath = nanCleanUp(newInfillPath);
    
    
end




