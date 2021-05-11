function [U,Sx,Sy,Sxy] = post_processing(n_element,KM,NDU,dzero,F,ncon,X,Y,E,A,v)
    
    for k = 1:NDU
        n = dzero(k);
        KM(n,:) = 0;
        KM(:,n) = 0;
        KM(n,n) = 1;
    end
    
    U = KM \ F;
    
    for i = 1:n_element
        n1 = ncon(i,1);
        n2 = ncon(i,2);
        n3 = ncon(i,3);
         
        x1 = X(n1);
        x2 = X(n2);
        x3 = X(n3);

        y1 = Y(n1);
        y2 = Y(n2);
        y3 = Y(n3);

        b1 = (y2 - y3);
        b2 = (y3 - y1);
        b3 = (y1 - y2);

        c1 = (x3 - x2);
        c2 = (x1 - x3);
        c3 = (x2 - x1);
        
        B = (1/(2*A)) * [b1 0 b2 0 b3 0
                    0 c1 0 c2 0 c3
                    c1 b1 c2 b2 c3 b3];
        D = (E/(1-v^2)) * [1 v 0
                            v 1 0
                            0 0 ((1-v)/2)];
                        
        u1 = U(2*n1 - 1);
        v1 = U(2*n1);
        u2 = U(2*n2 - 1);
        v2 = U(2*n2);
        u3 = U(2*n3 - 1);
        v3 = U(2*n3);
        
        d = [u1;v1;u2;v2;u3;v3];
        e = B * d;
        Sigma = D*e;
        Sx(i) = Sigma(1);
        Sy(i) = Sigma(2);
        Sxy(i) = Sigma(3);
        
    end
    
    Sx = Sx.';
    Sy = Sy.';
    Sxy = Sxy.';
    
end