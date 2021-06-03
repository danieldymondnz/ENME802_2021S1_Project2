% Function to create the cutter paths based off the Vector Cross Product
function slicePath = Layer_Builder(pX,pY,pZ,numLayers,layerT)
% Generates and rasterises layers for curved slicing of a free form surface
% defined by pX, pY, pZ for numLayers of layer thickness layerT.

    % Variables for Raster Path
    slicePath = [];
   
    % Convert the base layer pX, pY, pZ into a slice path
    slicePath = rasterBezier(pX,pY,pZ,1);

    if numLayers == 1
        return
    end
   
    % For each additional layer, generate and store the slicePath
    for layerNumber = 2:numLayers

        % Generate the layer
        [pX, pY, pZ] = generateLayer(pX, pY, pZ, layerT);
        
        % Convert to a Raster Path and Store
        slicePath = [slicePath; rasterBezier(pX,pY,pZ,layerNumber)];   

    end
    
end

function [pXdT, pYdT, pZdT] = generateLayer(pX, pY, pZ, layerThickness)
% Creates a new layer at layerThickness above the plane pX, pY, pZ

    % Flat Plane Tolerance
     tol = 1e-10;

    %Creates matrices to store the new x,y,z coordinates of the points
    pXdT = zeros(height(pX), length(pX));
    pYdT = zeros(height(pY), length(pY));
    pZdT = zeros(height(pZ), length(pZ));
    
    % For each of the points along the surface, find the points on the
    % layer above using vectors and append to pXdT, pYdT, pZdT
    for i = 1:height(pX)
        for j = 1:length(pX)
            
            % Obtain the coordinate from the matrices
            point = [pX(i,j) pY(i,j) pZ(i,j)];
            
            % If point is on the edge (i or j == 1), rotate V5 on the
            % x-axis
            if (i == 1)
                pointIP1 = [pX(i+1,j) pY(i+1,j) pZ(i+1,j)];
                V2 = pointIP1 - point;
                V5 = [V2(1) (-1)*V2(3) V2(2)];
                V5 = layerThickness * V5 / norm(V5);
           
            % Else if the point is on the edge (i or j == end), rotate V5
            % on the x-axis
            elseif (i == height(pX))
                pointIM1 = [pX(i-1,j) pY(i-1,j) pZ(i-1,j)];
                V1 = pointIM1 - point;
                V5 = [(V1(1)) V1(3) (-1)*V1(2)];
                V5 = layerThickness * V5 / norm(V5);
                
            % Otherwise, if point is in the middle
            else
                pointIP1 = [pX(i+1,j) pY(i+1,j) pZ(i+1,j)];
                pointIM1 = [pX(i-1,j) pY(i-1,j) pZ(i-1,j)];
                V1 = pointIM1 - point;
                V2 = pointIP1 - point;   
                
                % Find the normal vector using cross product of (V1, V2)
                V3 = cross(V1, V2);
                
                % If V3 is zero, then use rotation method
                if norm(V3) < tol
                    V5 = [(V1(1)) V1(3) (-1)*V1(2)];
                    V5 = layerThickness * V5 / norm(V5);
                
                % Otherwise, use cross product method
                else
                    if V3(1,1) < 0
                        V3 = -1 * V3;
                    end
                    
                    % Calculate V_13 and V_23
                    V_13 = cross(V1,V3) / norm(cross(V1,V3));
                    V_23 = cross(V3,V2) / norm(cross(V3,V2));

                    % Calculate V5
                    V5 = layerThickness * ((V_13 + V_23) / norm(V_13 + V_23));
                end
                
            end  
             
            %Add offset (V5) to location of the original point
            P_new = point + V5;

            %Add the new location of the points into the matrices
            pXdT(i,j) = P_new(1);
            pYdT(i,j) = P_new(2);
            pZdT(i,j) = P_new(3);
            
        end
            
    end
            
end
