% function [slicePath] = createInfillLayer(stl,sliceHeight,infillDistance,layer)
clear all

fileLocation = "Test Objects/Witcher_towel_hook.STL";

% Inputs
stl = stlread(fileLocation);
stl = stlTransform(stl, 0, 0, 0, 0, 0, 0, 100);

sliceHeight = 0.2;
sliceGen = FlatUniformSliceGenerator(stl,sliceHeight);

layer = 16.8;

% Set infill Distance
infillDistance = 2;

% This will be handled by Module 2 GUI
slicePath = sliceGen.getSlicePath;
layerPath = sliceGen.slicePathLayer(layer);

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
%     
%         if i~=1
%         polygonPrev = polygonCurr;
%         end
%         polygonCurr =  polyshape( layerPath(  min(temp):max(temp) , 1 ),layerPath( min(temp):max(temp),2));
%         plot(polygonCurr);
%         hold on
%         if i~=1
%         layerPolygon = union(polygonPrev,polygonCurr);
%         plot(layerPolygon);
%         end
    x = layerPath(  min(temp):max(temp) , 1 );
    y = layerPath( min(temp):max(temp),2);
    polyHeight = height(polyLayerPath);
    if isempty(polyLayerPath)
        polyLayerPath(:,1) = x;
        polyLayerPath(:,2) = y;
    else
        polyLayerPath(polyHeight+1:polyHeight+height(x) , 1) = x;
        polyLayerPath(polyHeight+1:polyHeight+height(y) , 2) = y;

    end 
polyLayerPath(height(polyLayerPath)+1,1:2) = NaN;
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
infillPath = [];
flip = 1;
% plot(layerPolygon);
for i=1:height(res)
    % Create current line to cut the shape.
    lineseg = [res(i,:) minLineseg(1,1); res(i,:) maxLineseg(1,1)];


    [in,out] = intersect(layerPolygon,lineseg);

    % Append to new array
    if height(infillPath) == 0 && ~isempty(in)
        infillPath = in;
    elseif ~isempty(in)
        infillPath(end+1,:) = infillPath(end,1:2);
        % Flip flop to alternate to draw lines bottom and top.
        if flip ==1
            infillPath(end+1:(end)+height(in),1:2) = flipud(in(:,1:2));
            flip = 2;
        else
            infillPath(end+1:(end)+height(in),1:2) = in(:,1:2);
            flip = 1;
        end
%             plot(infillPath(:,1),infillPath(:,2));
    end

%         plot(in(:,1),in(:,2),'b');
    hold on;
end

%%%%%%%%%% THIS IS ALL YOU NEED TO PLOT IT DANIEL%%%%%%%%%
plot(infillPath(:,1),infillPath(:,2));
% end

