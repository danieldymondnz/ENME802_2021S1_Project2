function sliceSarat()

[F,V,N] = stlread('Test3.STL');
F = evalin('base','F');

ncon = F.ConnectivityList;

n_nodes = height(ncon)*2;
n_element = height(ncon);
X = F.Points(:,1);
Y = F.Points(:,2);
Z = F.Points(:,3);

% Create a For Loop to loop through all elements for verification
for i=1:n_element
    n1 = ncon(i,1);
    n2 = ncon(i,2);
    n3 = ncon(i,3);
    x1 = X(n1);
    x2 = X(n2);
    x3 = X(n3);
    y1 = Y(n1);
    y2 = Y(n2);
    y3 = Y(n3);
    z1 = Z(n1);
    z2 = Z(n2);
    z3 = Z(n3);
    P = [x1;x2;x3];
    Q = [y1;y2;y3];
    R = [z1;z2;z3];
    figure(1)
    patch(P,Q,R,'g')
    hold on;
end


% Find the maximum height from the base
zmax = max(Z)

% Define the number of slices and their Z positions
INC = 5; %5 units/per increment
NOSTEP = zmax/INC;
zs = 0;

% Loop through each incremental height to generate a slice


for i=1:NOSTEP - 1
    
    zs = zs+INC;
    C = 0;
    
    for j=1:n_element
        n1 = ncon(j,1);
        n2 = ncon(j,2);
        n3 = ncon(j,3);
        x1 = X(n1);
        x2 = X(n2);
        x3 = X(n3);
        y1 = Y(n1);
        y2 = Y(n2);
        y3 = Y(n3);
        z1 = Z(n1);
        z2 = Z(n2);
        z3 = Z(n3);

        % If any z point 1-2 cuts through slice
        if ((z1 <= zs && zs <= z2) || (zs <= z1 && z2 <= zs))
           
            C = C + 1;
            
            % If point is horizontal
            if (z1 == z2)
                XP(C) = x1;
                YP(C) = y1;
                ZP(C) = zs;
            
            % Otherwise, if not horizontal, determine the cut point
            else
                XP(C) = x1 + ((z1-zs)/(z1-z2))*(x2-x1);
                YP(C) = y1 + ((z1-zs)/(z1-z2))*(y2-y1);
                ZP(C) = zs;
            end
            
%         elseif (zs <= z1 && z2 <= zs)
%             
%             C = C + 1;
%             
%             % If point is horizontal
%             if (z1 == z2)
%                 XP(C) = x1;
%                 YP(C) = y1;
%                 ZP(C) = zs;
%             
%             % Otherwise, if not horizontal, determine the cut point
%             else
%                 XP(C) = x1 + ((z1-zs)/(z1-z2))*(x2-x1);
%                 YP(C) = y1 + ((z1-zs)/(z1-z2))*(y2-y1);
%                 ZP(C) = zs;
%             end
            
        end
        
        % If any z point of line 2-3 cuts through, then slice
        if ((z2 <= zs && zs <= z3) || (zs <= z2 && z3 <= zs))
           
            C = C + 1;
            
            % If point is horizontal
            if (z2 == z3)
                XP(C) = x2;
                YP(C) = y2;
                ZP(C) = zs;
            
            % Otherwise, if not horizontal, determine the cut point
            else
                XP(C) = x2 + ((z2-zs)/(z2-z3))*(x3-x2);
                YP(C) = y2 + ((z2-zs)/(z2-z3))*(y3-y2);
                ZP(C) = zs;
            end
            
        end
        
        % If any z point of line 3-1 cuts through, then slice
        if ((z3 <= zs && zs <= z1) || (zs <= z3 && z1 <= zs))
           
            C = C + 1;
            
            % If point is horizontal
            if (z3 == z1)
                XP(C) = x3;
                YP(C) = y3;
                ZP(C) = z3;
            
            % Otherwise, if not horizontal, determine the cut point
            else
                XP(C) = x3 + ((z3-zs)/(z3-z1))*(x1-x3);
                YP(C) = y3 + ((z3-zs)/(z3-z1))*(y1-y3);
                ZP(C) = zs;
            end
            
        end
        
    end
    
    % Now, plot
figure(2)
plot3(XP,YP,ZP,'-r*','LineWidth',2);
view(3);
hold on

figure(3)
patch(XP,YP,ZP,'r')
view(3);
hold on
    
end

end