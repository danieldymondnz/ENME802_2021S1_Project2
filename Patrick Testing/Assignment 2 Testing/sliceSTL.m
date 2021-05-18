function sliceSTL(X,Y,Z,connections,planeEquation,inc)
zmax = max(Z);
Intercepts1 = zeros(3);
Intercepts2 = zeros(3);
Intercepts3 = zeros(3);
counter1 = 1;
counter2 = 1;
counter3 = 1;
sliceHeight = 0;
%go through all points until hits zmax
for j = 0:(zmax/inc)
    syms t x y z k;
    sliceHeight = sliceHeight+inc;
    for i=1:height(connections)
    %find equations for line 1 of triangle pts(1,2)
    line1X1 = X(connections(i,1));
    line1Y1 = Y(connections(i,1));
    line1Z1 = Z(connections(i,1));
    
    line1X2 = X(connections(i,2));
    line1Y2 = Y(connections(i,2));
    line1Z2 = Z(connections(i,2));
    
    %find equations for line 2 of triangle pts(1,3)
    line2X1 = X(connections(i,1));
    line2Y1 = Y(connections(i,1));
    line2Z1 = Z(connections(i,1));
    
    line2X2 = X(connections(i,3));
    line2Y2 = Y(connections(i,3));
    line2Z2 = Z(connections(i,3));
    
    %find equations for line 3 of triangle pts(2,3)
    line3X1 = X(connections(i,2));
    line3Y1 = Y(connections(i,2));
    line3Z1 = Z(connections(i,2));
    
    line3X2 = X(connections(i,3));
    line3Y2 = Y(connections(i,3));
    line3Z2 = Z(connections(i,3));
    
    
    
    %find equations of line by vectorizing them.
    %vector = <x2-x1,y2-y1,z2-z1> = <a,b,c>
    %Parametric equations are X = X0 +a*t , Y = Y0 + b*t , Z = Z0 + c*t.
    line1XEquation = line1X1 + (line1X2-line1X1)*t;
    line1YEquation = line1Y1 + (line1Y2-line1Y1)*t;
    line1ZEquation = line1Z1 + (line1Z2-line1Z1)*t;
    
    line2XEquation = line2X1 + (line2X2-line2X1)*t;
    line2YEquation = line2Y1 + (line2Y2-line2Y1)*t;
    line2ZEquation = line2Z1 + (line2Z2-line2Z1)*t;
    
    line3XEquation = line3X1 + (line3X2-line3X1)*t;
    line3YEquation = line3Y1 + (line3Y2-line3Y1)*t;
    line3ZEquation = line3Z1 + (line3Z2-line3Z1)*t;
    
    
    
    %PLOT LINES HERE TO SEE
%     figure(1)
%     view(3)
%     hold on;
%     
%     line1P1 = [line1X1,line1Y1,line1Z1];
%     line1P2 = [line1X2,line1Y2,line1Z2];
%     pts1 = [line1P1;line1P2];
%     line(pts1(:,1), pts1(:,2), pts1(:,3));
%     
%     line2P1 = [line2X1,line2Y1,line2Z1];
%     line2P2 = [line2X2,line2Y2,line2Z2];
%     pts2 = [line2P1;line2P2];
%     line(pts2(:,1), pts2(:,2), pts2(:,3));
%     
%     line3P1 = [line3X1,line3Y1,line3Z1];
%     line3P2 = [line3X2,line3Y2,line3Z2];
%     pts3 = [line3P1;line3P2];
%     line(pts3(:,1), pts3(:,2), pts3(:,3));
    
    
    %sub into plane equation
    %equation of plane is: x + y + z = c
    %layout planeEquation as [x y z] 
    %leave c as it is the increment of for loop.
%     disp(planeEquation)
    interceptEquation1 = subs(planeEquation,[x y z],[line1XEquation,line1YEquation,line1ZEquation]) == sliceHeight;
    interceptEquation2 = subs(planeEquation,[x y z],[line2XEquation,line2YEquation,line2ZEquation]) == sliceHeight;
    interceptEquation3 = subs(planeEquation,[x y z],[line3XEquation,line3YEquation,line3ZEquation]) == sliceHeight;
    
%     disp(interceptEquation1)
    
    tSolved1 = solve(interceptEquation1,t);
    tSolved2 = solve(interceptEquation2,t);
    tSolved3 = solve(interceptEquation3,t);
    

    
    %sub tSolved back into original x y z equations to find Intercept.
    xIntercept1 = line1X1 + (line1X2-line1X1)*tSolved1;
    yIntercept1 = line1Y1 + (line1Y2-line1Y1)*tSolved1;
    zIntercept1 = line1Z1 + (line1Z2-line1Z1)*tSolved1;
    
    xIntercept2 = line2X1 + (line2X2-line2X1)*tSolved2;
    yIntercept2 = line2Y1 + (line2Y2-line2Y1)*tSolved2;
    zIntercept2 = line1Z1 + (line1Z2-line1Z1)*tSolved2;
    
    xIntercept3 = line3X1 + (line3X2-line3X1)*tSolved3;
    yIntercept3 = line3Y1 + (line3Y2-line3Y1)*tSolved3;
    zIntercept3 = line3Z1 + (line3Z2-line3Z1)*tSolved3;
    
    if (~isempty(xIntercept1) || ~isempty(yIntercept1) || ~isempty(zIntercept1) )
        
        %find normal vector to plane
        %project points 1 and 2 to plane, and see if intercepts are inside
        %within those projections.
        
        %normal vector of plane are coefficients <Ax By Cz>
        
        
        %check if intercept is inside of the line.
%         if (xIntercept >= x1 && xIntercept <= x2) && (yIntercept >= y1 && yIntercept <= y2) && (zIntercept >= z1 && zIntercept <= z2) || (xIntercept >= x2 && xIntercept <= x1) && (yIntercept >= y2 && yIntercept <= y1) && (zIntercept >= z2 && zIntercept <= z1)
            Intercepts1(counter1,1) = xIntercept1;
            Intercepts1(counter1,2) = yIntercept1;
            Intercepts1(counter1,3) = zIntercept1;
            
            
            
            
            counter1 = counter1 + 1;
            
            
%         end
        
   
    end
    
    if (~isempty(xIntercept2) || ~isempty(yIntercept2) || ~isempty(zIntercept2) )
        Intercepts2(counter2,1) = xIntercept2;
        Intercepts2(counter2,2) = yIntercept2;
        Intercepts2(counter2,3) = zIntercept2;
        
        counter2 = counter2 + 1;
    end
    
    if ( ~isempty(xIntercept3) || ~isempty(yIntercept3) || ~isempty(zIntercept3) )
        Intercepts3(counter3,1) = xIntercept3; 
        Intercepts3(counter3,2) = yIntercept3;
        Intercepts3(counter3,3) = zIntercept3;
        counter3 = counter3 + 1;
    end
    
    end
    
%     disp(sliceHeight)
    figure(1);
    hold on;
    view(3);
    scatter3(Intercepts1(:,1),Intercepts1(:,2),Intercepts1(:,3));
    scatter3(Intercepts2(:,1),Intercepts2(:,2),Intercepts2(:,3));  
    scatter3(Intercepts3(:,1),Intercepts3(:,2),Intercepts3(:,3));  

end


end