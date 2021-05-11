function display_structure(n_element,ncon,X,Y,U)
    
    for i = 1:n_element
        
        n1 = ncon(i,1);
        n2 = ncon(i,2);
        n3 = ncon(i,3);
        
        x1 = X(n1);
        x2 = X(n2);
        x3 = X(n3);
        x4 = x1;

        y1 = Y(n1);
        y2 = Y(n2);
        y3 = Y(n3);
        y4 = y1;
        
        u1 = U(2*n1 - 1);
        v1 = U(2*n1);
        u2 = U(2*n2 - 1);
        v2 = U(2*n2);
        u3 = U(2*n3 - 1);
        v3 = U(2*n3);
        
        multiplier = 10000;
        xf1 = X(n1) + multiplier * u1;
        xf2 = X(n2) + multiplier * u2;
        xf3 = X(n3) + multiplier * u3;
        xf4 = xf1;
        yf1 = Y(n1) + multiplier * v1;
        yf2 = Y(n2) + multiplier * v2;
        yf3 = Y(n3) + multiplier * v3;
        yf4 = yf1;
        
        plot([xf1 xf2 xf3 xf4], [yf1 yf2 yf3 yf4], 'LineWidth', 5, 'Color', 'red')
        hold on;
        plot([x1 x2 x3 x4], [y1 y2 y3 y4], 'LineWidth', 2)
        hold on;
        plot([x1 x2 x3 x4], [y1 y2 y3 y4], 'ro')
        
    end
end