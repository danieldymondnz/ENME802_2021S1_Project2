function stlRotated = stlRotate(stl)
X = stl.Points(:,1);
Y = stl.Points(:,2);
Z = stl.Points(:,3);

 
stlRotated.Points = [Z,X,Y];
stlRotated.ConnectivityList = stl.ConnectivityList;

end