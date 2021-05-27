fileLocation = "Test Objects/cubewithhole.STL";

% Inputs
stl = importSTL(fileLocation);
stl = stlTransform(stl, 90, 0, 0, 1, 0, 0, 0, 100);
sliceHeight = 0.2;
sliceGen = FlatUniformSliceGenerator(stl,sliceHeight);
layer = 50;

slicePath = sliceGen.getSlicePath;
layerPath = sliceGen.slicePathLayer(layer);

% find how many parts the layerPath has, do a for loop for that.
% for each part, generate a infill path by code below...

% Generate Polygon for Infill

sliceSize = max(max(layerPath(:,1:2))); % Calculate max x and y
t = 0:0.001:sliceSize;

% f increases the size of the infill. size of gap = 1/f units.
f = 2 ;

sq = sliceSize*(square(pi*f*t)+1);
infillPolygon = polyshape(t,sq);
% plot(infillPolygon);

numOfparts = max(layerPath(:,4));
for i = 1: numOfparts
    
    temp = find(ismember(layerPath(:,4),i,'rows'));
    
    layerPolygon =  polyshape( layerPath(  min(temp):max(temp) , 1 ),layerPath( min(temp):max(temp),2));
    %     plot(layerPolygon);
    [in, out] = intersect(layerPolygon,infillPolygon);
    
    inSort = sortrows(in.Vertices,1); % Sort infill path by x axis
    plot(inSort(:,1),inSort(:,2)); % Plot infill sorted path.
    
    hold on;
    
    
    %%%%%%%%%%% gap detection experiment %%%%%%%%%%%
%     for j = 1:height(inSort)-1
%     inc = 1;
%     while inc <= height(inSort)-2
%  
%         %find how many points are on same x axis.
%         idx = find(ismember(round(inSort(:,1),1), round(inSort(inc,1),1) ));
%         
%         if sum(idx) > 1
%             for k = 1:height(idx)-2
%                 pt1 = inSort(idx(2*k-1),1:2);
%                 pt2 = inSort(idx(2*k),1:2);
%                 plot( pt1 , pt2 );
%                 hold on;
%                 
%             end
%         inc = inc+2;
%         else
%             inc = inc + 1;
%         end
%         
%               
%     end
end







hold on;





% figure(2);
% plot(in);


