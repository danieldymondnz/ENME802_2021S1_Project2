function [F,V,N] = importSTL(stlFile)
% figure
% model = createpde;
% gm = importGeometry(model,'Test.STL');
% pdegplot(model)

% mesh = generateMesh(model,'GeometricOrder','linear');

% nodes = mesh.Nodes;

% figure
%node(1,:) x axis
%node(2,:) y axis
%node(3,:) z axis
% scatter3(nodes(1,:),nodes(2,:),nodes(3,:))

% figure
% pdemesh(model)

[F,V,N] = stlread(stlFile);

end