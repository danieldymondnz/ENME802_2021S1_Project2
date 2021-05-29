%Function to create the cutter paths based off the Vector Cross Product

function layer_paths = Layer_Builder(Px,Py,Pz,N_layers,layerT)
   % Plot the original data for debug
   plot3(Px,Py,Pz)
   hold on

   %Convert the matrices of coordinates of the points into a single array
   %of x,y,z coordinates
   Points = [];
    for i = 1:height(Px)
        for j = 1:length(Px)
            Points = [Points;Px(i,j),Py(i,j),Pz(i,j)];
        end
    end
    Points;
    
    %Create matrices to store the new x,y,z coordinates of the points in
    PxdT = zeros(height(Px));
    PydT = zeros(height(Py));
    PzdT = zeros(height(Pz));
    
    for i = 1:height(Px)
        for j = 1:length(Px)
            point = [Px(i,j) Py(i,j) Pz(i,j)];
            if (i == 1 || j == 1) %Ignore the very first point (edge)
                
            elseif (i == height(Px) || j == height(Px)) %Ignore the very last point (edge)
                    
            else
                    %Calculate the location of the new point offset using vector
                    %cross product method
                    V3 = [0 0 -1];  
                    pointIP1 = [Px(i+1,j) Py(i+1,j) Pz(i+1,j)];
                    pointIM1 = [Px(i-1,j) Py(i-1,j) Pz(i-1,j)];
                    V1 = pointIM1 - point;
                    V2 = pointIP1 - point;
                    V_13 = (1/layerT)*((cross(V1,V3))/(norm(cross(V1,V3))));
                    V_23 = (1/layerT)*((cross(V3,V2))/(norm(cross(V3,V2))));
                    alpha = acosd(dot(V_13,V_23)/((norm(V_13))*(norm(V_23))));
                    V5 = ((1/layerT)/(cos(alpha/2)))*((V_13 + V_23)/(norm(V_13 + V_23)));
                    
                    %Add the offset (V5) to the location of the original
                    %point
                    P_new = point + V5;
                    
                    %Add the new location of the points into the matrices
                    PxdT(i,j) = P_new(1);
                    PydT(i,j) = P_new(2);
                    PzdT(i,j) = P_new(3);
            end          
        end
    end
    
%Ignore the first and last points (edges)
size = height(PxdT);
PxdT = PxdT(2:size - 1, 2:size-1);
PydT = PydT(2:size - 1, 2:size-1);
PzdT = PzdT(2:size - 1, 2:size-1);

%Plot the new cutter paths with the updated point locations
plot3(PxdT,PydT,PzdT)