function obj = importSTL(fileLocation)

    % Keep reference to the number of vertices stored in the matrix
    verticesStored = 0;
    
    % Create the Point Maps
    xMap = containers.Map('KeyType','double','ValueType','double');
    yMap = containers.Map('KeyType','double','ValueType','double');
    zMap = containers.Map('KeyType','double','ValueType','double');


% fileLocation = "Test Objects\Box.STL";
fid = fopen(fileLocation);

% data = fread(fid);
% header = data(1:80);

% headerLength = fread(fid,80,'int8');
% title2 = convertCharsToStrings( native2unicode(headerLength,'ascii') ) ;

% look for endSolid at the end, and if it exists then end the code.

frewind(fid); % Go back to top of fid binary.
header = fread(fid,80,'int8');
title = convertCharsToStrings( native2unicode(header,'ascii') );

if contains(title,"facet normal")
    %     error('ERROR: Please provide an STL file that is encoded in Binary not ASCII. MATLAB can not handle the amount of bytes in ASCII STLs''')
    %     return
    format = "ascii";
else
    format = "binary";
end

if strcmp(format,"binary")
    
    frewind(fid); % Go back to top of fid binary.
    header = fread(fid,80,'int8');
    title = convertCharsToStrings( native2unicode(header,'ascii') );
    
    % nfaces = data(81);
    nfaces = fread(fid,1,'int32');
    
    nvert = 3*nfaces; % number of vertices
    
    points = zeros(nvert,3);
    connectivityList = zeros(nfaces,3);
    
    
    for i = 1:nfaces
        data = fread(fid,12,'float');
        % first 12 bytes or, first 3 items are normal vector.
        % next 12 are x,y,z coordinates of point 1, 2 and 3.
        
        point1 = data(4:6);
        point2 = data(7:9);
        point3 = data(10:12);
        
        index1 = 3*i-2;
        index2 = 3*i-1;
        index3 = 3*i;
        %     connectivityList(i,:) = [3*i-2 3*i-1 3*i]; % connectivity list pattern
        
        % Check here if x y z coordinates already exists.
        if( sum( ismember(points,[point1(1,1) point1(2,1) point1(3,1)],'rows') ) >=1)
            index1 = find(ismember(points,[point1(1,1) point1(2,1) point1(3,1)],'rows'));
            index1 = index1(1);
        else
            points(i*3-2,:) = point1; % coordinates of point 1
        end
        
        
        if( sum( ismember(points,[point2(1,1) point2(2,1) point2(3,1)],'rows') ) >=1)
            index2 = find(ismember(points,[point2(1,1) point2(2,1) point2(3,1)],'rows'));
            index2 = index2(1);
        else
            points(i*3-1,:) = point2; % %coordinates of point 2
        end
        
        
        if( sum( ismember(points,[point3(1,1) point3(2,1) point3(3,1)],'rows') ) >=1)
            index3 = find(ismember(points,[point3(1,1) point3(2,1) point3(3,1)],'rows'));
            index3 = index3(1);
        else
            points(i*3,:) = point3; % %coordinates of point 3
        end
        
        
        
        
        
        connectivityList(i,:) = [index1 index2 index3]; % connectivity list pattern
        fread(fid,1,'int16'); % skip to Attribute byte count
    end
    
    
    % obj = triangulation(connectivityList,points);
    fclose(fid);
    obj = triangulation(connectivityList,points);
    
    % ASCII PART
else
    frewind(fid);
    %     textscan(fid,'%s','delimiter','\n');
    data = fread(fid,'int8');
    data = convertCharsToStrings( native2unicode(data,'ascii'));
    %     data = replace(data,'↵','');
    data = splitlines(data);
    
    title = data(1);
    
    % nfaces = data(81);
    nfaces = sum(contains(data,"endfacet"));
    
    nvert = 3*nfaces; % number of vertices
    
    points = zeros(nvert,3);
    connectivityList = zeros(nfaces,3);
    
    
    for i=1:sum(contains(data,"endfacet"))
        temp = data((i*7-5):(i*7+1));
        
        temp1 = split( strtrim(temp(3)), ' ' );
        %         point1 = [str2double(temp1(2));str2double(temp1(3));str2double(temp1(4))];
        point1 = str2double(temp1(2:end));
        temp2 = split( strtrim(temp(4)), ' ' );
        %         point2 = [str2double(temp2(2));str2double(temp2(3));str2double(temp2(4))];
        point2 = str2double(temp2(2:end));
        temp3 = split( strtrim(temp(5)), ' ' );
        %         point3 = [str2double(temp3(2));str2double(temp3(3));str2double(temp3(4))];
        point3 = str2double(temp3(2:end));
        
        index1 = 3*i-2;
        index2 = 3*i-1;
        index3 = 3*i;
        
        % Get the indexes of the X, Y, Z coordinates
        
        [index1, verticesStored] = getVertice(point1(1,1), point1(2,1), point1(3,1), xMap, yMap, zMap, verticesStored);
        [index2, verticesStored] = getVertice(point2(1,1), point2(2,1), point2(3,1), xMap, yMap, zMap, verticesStored);
        [index3, verticesStored] = getVertice(point3(1,1), point3(2,1), point3(3,1), xMap, yMap, zMap, verticesStored);
        
        [verticeIndex, verticesStored] = getVertice(xPos, yPos, zPos, xMap, yMap, zMap, verticesStored)
        
%         Check here if x y z coordinates already exists.
%         if( sum( ismember(points,[point1(1,1) point1(2,1) point1(3,1)],'rows') ) >=1)
%             index1 = find(ismember(points,[point1(1,1) point1(2,1) point1(3,1)],'rows'));
%             index1 = index1(1);
%         else
%             points(i*3-2,:) = point1; % coordinates of point 1
%         end
%         
%         
%         if( sum( ismember(points,[point2(1,1) point2(2,1) point2(3,1)],'rows') ) >=1)
%             index2 = find(ismember(points,[point2(1,1) point2(2,1) point2(3,1)],'rows'));
%             index2 = index2(1);
%         else
%             points(i*3-1,:) = point2; % %coordinates of point 2
%         end
%         
%         
%         if( sum( ismember(points,[point3(1,1) point3(2,1) point3(3,1)],'rows') ) >=1)
%             index3 = find(ismember(points,[point3(1,1) point3(2,1) point3(3,1)],'rows'));
%             index3 = index3(1);
%         else
%             points(i*3,:) = point3; % %coordinates of point 3
%         end
        
        
        connectivityList(i,:) = [index1 index2 index3]; % connectivity list pattern
        
    end
    
    fclose(fid);
    obj = triangulation(connectivityList,points);
end


end

% 
function [verticeIndex, verticesStored] = getVertice(xPos, yPos, zPos, xMap, yMap, zMap, verticesStored)

    matchFound = 0;
    matchingXVertices = [];
    matchingYVertices = [];
    matchingZVertices = [];
    
    if (xMap.isKey(xPos) && yMap.isKey(yPos) && zMap.isKey(zPos))

        % Get the Pairs from the maps
        matchingXVertices = xMap(xPos);
        matchingYVertices = yMap(yPos);
        matchingZVertices = zMap(zPos);

        % If either of the three results are length 0, then a point is not
        % common and should be created
        if (isempty(matchingXVertices)) || (isempty(matchingYVertices)) || (isempty(matchinZXVertices))
           matchFound = 0;

        % Otherwise, if a common verticeIndex is shared among the three maps, then the
        % vertice already exists
        else
            [xyIndexes, ~] = intersect(matchingXVertices, matchingYVertices);
            [yzIndexes, ~] = intersect(matchingYVertices, matchingZVertices);
            [index, ~] = intersect(xyIndexes, yzIndexes);

            if ~isempty(index)
                matchFound = 1;
            end

        end
    end
    
    if matchFound == 1
        verticeIndex = index;
        verticesStored = verticesStored;
    
    % Otherwise, generate a new pair
    else
        verticesStored = verticesStored + 1;
        verticeIndex = verticesStored;
        xMap(xPos) = [matchingXVertices, verticesStored];
        yMap(yPos) = [matchingYVertices, verticesStored];
        zMap(xPos) = [matchingZVertices, verticesStored];
    end
    
end


