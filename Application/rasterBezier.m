function [rasterPath] = rasterBezier(Px,Py,Pz,layerN)
% Collects and connects the cutter paths 

rasterPath = []; 
i = 1;
j = 0;

%While on a cutter path store the coordinates of those points, otherwise
%connect the ends of the cutter paths together
while (i <= height(Px))
    
    if (j == 0)
        j = 1;
    else 
        j = length(Px);
    end
    
    %Joins the cutter paths together
    dPx = 1 - 2*(mod((i+1),2));
        
    while (j >= 1 && j <= length(Px))
        rasterPath = [rasterPath; Px(i,j), Py(i,j), Pz(i,j), layerN];
        j = j + dPx; 
    end 
    i = i+1;
end

end

