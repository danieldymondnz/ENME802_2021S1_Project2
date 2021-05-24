function obj = importSTL(fileLocation)

% fileLocation = "Test Objects\Box.STL";
fid = fopen(fileLocation);

% data = fread(fid); 
% header = data(1:80);
header = fread(fid,80,'int8');
title = native2unicode(header,'ascii');

% nfaces = data(81);
nfaces = fread(fid,1,'int32');

nvert = 3*nfaces; % number of vertices

points = zeros(nvert,3);
connectivityList = zeros(nfaces,3);


for i = 1:nfaces 
    data = fread(fid,12,'float');
    % first 12 bytes or, first 3 items are normal vector.
    % next 12 are x,y,z coordinates of point 1, 2 and 3.
    
    % Check here if x y z coordinates already exists.
    
    point1 = data(4:6);
    point2 = data(7:9);
    point3 = data(10:12);
    
    points(i*3-2,:) = point1; % coordinates of point 1
    points(i*3-1,:) = point2; % %coordinates of point 2
    points(i,:) = point3; % %coordinates of point 3
    
    connectivityList(i,:) = [3*i-2 3*i-1 3*i]; % connectivity list pattern
    fread(fid,1,'int16'); % skip to Attribute byte count 
end

obj = triangulation(connectivityList,points);
fclose(fid);

