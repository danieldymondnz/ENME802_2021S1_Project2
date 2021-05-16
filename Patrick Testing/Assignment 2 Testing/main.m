importSTL;

X = F.Points(:,1);
Y = F.Points(:,2);
Z = F.Points(:,3);
connections = F.ConnectivityList;
planeEquation = setPlaneEquation(0,0,0,0,1,1);



sliceSTL(X,Y,Z,connections,planeEquation);