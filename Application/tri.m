function [tria] = tri(Px,Py,Pz)

% Taking in all the points that exist on the Bezier Surface
n = height(Px);                                                             % n parameter derived from generated Px
m = width(Px);                                                              % m parameter derived from generated Px
points = zeros(n*m,3);                                                      % Pre-acllocated points matrix 
currrow = 1;                                                                % Counter to append

for i = 1:n
    for j = 1:m
        points(currrow,:) = [Px(i,j),Py(i,j),Pz(i,j)];
        currrow = currrow+1;
    end
end

% Generating connectivity list for triangulation for the surface
conlist = [];                                                               % Pre-allocated connectivity list                              
for i = 1:n-1                                       
     for j = 1:m-1
         point1 = n*(i-1)+j;                                                % Based on OneNote drawing (i.e. how each point for each square on the Bezier surace is analysed)
         point2 = n*(i-1)+j+1;
         point3 = n*(i)+j;
         point4 = n*(i)+j+1;
         
         conlist = [conlist;point1,point3,point4;point1,point4,point2];     % Genrating connectivity matrix based on equations for each point on the surface      
     end
 end 
tria = triangulation(conlist,points);                                       % Output (to be called in main) 
end 