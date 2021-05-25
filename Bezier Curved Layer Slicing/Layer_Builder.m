function layer_paths = Layer_Builder(Px,Py,Pz,N_layers,layerT)
    % Plot the original data for debug
   plot3(Px,Py,Pz)
   hold on

    Points = [];
    for i = 1:height(Px)
        for j = 1:length(Px)
            Points = [Points;Px(i,j),Py(i,j),Pz(i,j)];
        end
    end
    Points;
    
    PxdT = zeros(height(Px));
    PydT = zeros(height(Py));
    PzdT = zeros(height(Pz));
    
    for i = 1:height(Px)
        for j = 1:length(Px)
            point = [Px(i,j) Py(i,j) Pz(i,j)];
            if (i == 1 || j == 1)
              
            elseif (i == height(Px) || j == height(Px))
                    
                else
                    V3 = [0 0 1];  
                    pointIP1 = [Px(i+1,j) Py(i+1,j) Pz(i+1,j)];
                    pointIM1 = [Px(i-1,j) Py(i-1,j) Pz(i-1,j)];
                    V1 = pointIM1 - point;
                    V2 = pointIP1 - point;
                    V_13 = (layerT)*((cross(V1,V3))/(norm(cross(V1,V3))));
                    V_23 = (layerT)*((cross(V3,V2))/(norm(cross(V3,V2))));
                    alpha_r = acos(dot(V_13,V_23)/(norm(V_13)*norm(V_23)));
                    alpha_d = (alpha_r*180)/(pi);
                    V5 = (layerT/(cos(alpha_d/2)))*((V_13 + V_23)/(norm(V_13) + norm(V_23)));
                    
                    P_new = point + V5;
                    
                    PxdT(i,j) = P_new(1);
                    PydT(i,j) = P_new(2);
                    PzdT(i,j) = P_new(3);
            end
                    
    
        end
    end

size = height(PxdT);

PxdT = PxdT(2:size - 1, 2:size-1);
PydT = PydT(2:size - 1, 2:size-1);
PzdT = PzdT(2:size - 1, 2:size-1);

plot3(PxdT,PydT,PzdT)

