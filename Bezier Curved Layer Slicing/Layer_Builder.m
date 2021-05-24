function layer_paths = Layer_Builder(Px,Py,Pz,N_layers,layerT)
%LAYER_BUILDER Summary of this function goes here
%   Detailed explanation goes here
Points = [];
for i = 1:height(Px)
    for j = 1:length(Px)
        Points = [Points;Px(i,j);Py(i,j);Pz(i,j)];
    end
end
end

