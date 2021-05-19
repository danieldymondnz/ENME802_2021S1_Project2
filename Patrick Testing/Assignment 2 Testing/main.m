clear;

stl = importSTL('Box.STL');

X = stl.Points(:,1);
Y = stl.Points(:,2);
Z = stl.Points(:,3);
connections = stl.ConnectivityList;
planeEquation = setPlaneEquation(1,2,0,0,1,1);

drawSTL(X,Y,Z,connections);

sliceSTL(X,Y,Z,connections,planeEquation,10);