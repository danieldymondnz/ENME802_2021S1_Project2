function obj = importSTL(fileLocation)

    % Store the list of points/vertices and maintain a reference to it's
    % length for the HashMaps
    verticesStored = 0;
    points = [];
    tollerance = 4;

    % Create the Point Maps
    xMap = containers.Map('KeyType','double','ValueType','any');
    yMap = containers.Map('KeyType','double','ValueType','any');
    zMap = containers.Map('KeyType','double','ValueType','any');

    % Open the STL File
    fid = fopen(fileLocation);

    %frewind(fid); % Go back to top of fid binary.
    header = fread(fid,80,'int8');
    title = convertCharsToStrings( native2unicode(header,'ascii') );
    
    % Determine if the file is in Binary or ASCII
    if contains(title,"facet normal")
        isBinary = 0;
    else
        isBinary = 1;
    end

    % If the file is Binary, then read as Binary File
    if isBinary
    
        frewind(fid); % Go back to top of fid binary.
        header = fread(fid,80,'int8');
        title = convertCharsToStrings( native2unicode(header,'ascii') );

        % nfaces = data(81);
        nfaces = fread(fid,1,'int32');

        nvert = 3*nfaces; % number of vertices

        %points = zeros(nvert,3);
        connectivityList = zeros(nfaces,3);

        % For each of the elements/faces
        for i = 1:nfaces

            % first 12 bytes or, first 3 items are normal vector.
            data = fread(fid,12,'float');

            % next 12 are x,y,z coordinates of point 1, 2 and 3.
            point1 = data(4:6);
            point2 = data(7:9);
            point3 = data(10:12);

            % Lookup Vertices in Hash Maps and return the point index for each
            % vertice.
            [index1, verticesStored, points] = getVertice(point1(1,1), point1(2,1), point1(3,1), xMap, yMap, zMap, verticesStored, points);
            [index2, verticesStored, points] = getVertice(point2(1,1), point2(2,1), point2(3,1), xMap, yMap, zMap, verticesStored, points);
            [index3, verticesStored, points] = getVertice(point3(1,1), point3(2,1), point3(3,1), xMap, yMap, zMap, verticesStored, points);

            % Add the element to the Connectivity List
            connectivityList(i,:) = [index1 index2 index3];

            % skip to Attribute byte count
            fread(fid,1,'int16');

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

        %points = zeros(nvert,3);
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

            [index1, verticesStored, points] = getVertice(point1(1,1), point1(2,1), point1(3,1), xMap, yMap, zMap, verticesStored, points);
            [index2, verticesStored, points] = getVertice(point2(1,1), point2(2,1), point2(3,1), xMap, yMap, zMap, verticesStored, points);
            [index3, verticesStored, points] = getVertice(point3(1,1), point3(2,1), point3(3,1), xMap, yMap, zMap, verticesStored, points);

            %[verticeIndex, verticesStored] = getVertice(xPos, yPos, zPos, xMap, yMap, zMap, verticesStored)


            connectivityList(i,:) = [index1 index2 index3]; % connectivity list pattern

        end

        %points = generatePointsList(xMap, yMap, zMap, verticesStored);

        fclose(fid);
        obj = triangulation(connectivityList,points);
    end


end

%
function [verticeIndex, verticesStored, points] = getVertice(xPos, yPos, zPos, xMap, yMap, zMap, verticesStored, points)

    matchFound = 0;
    matchingXVertices = [];
    matchingYVertices = [];
    matchingZVertices = [];
    
    % Get the Pairs from the maps
    isX = xMap.isKey(xPos);
    if isX
       matchingXVertices = xMap(xPos);
    end
    
    isY = yMap.isKey(yPos);
    if isY
        matchingYVertices = yMap(yPos);
    end
    
    isZ = zMap.isKey(zPos);
    if isZ
         matchingZVertices = zMap(zPos);
    end
    

    if (isX && isY && isZ)

        % If either of the three results are length 0, then a point is not
        % common and should be created
        if (isempty(matchingXVertices)) || (isempty(matchingYVertices)) || (isempty(matchingZVertices))
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
        xMap(xPos) = [matchingXVertices, verticeIndex];
        yMap(yPos) = [matchingYVertices, verticeIndex];
        zMap(zPos) = [matchingZVertices, verticeIndex];
        points(verticeIndex,:) = [xPos, yPos, zPos];
    end

end