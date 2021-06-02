function [Px,Py,Pz] = GenerateBezierCurve(Bx,By,Bz,res)
n = height(Bz);                                                             % Parameter n is found using the height of the user specified matrix

% Berstein functions for paramters is as follows (gained from class) 
for i = 1:n
    for j=1:n
        if (i+j-1<=n)
            N(i,j) = (factorial(n-1)/(factorial(j-1)*factorial(i-1)*factorial(n-i-j+1)))*((-1)^(n-i-j+1));
        else 
            N(i,j) = 0;
        end 
    end 
end 

NT = transpose(N);                                                          % Transpose N matrix above 

% Main routine (calculate points for each coordinate)
for i = 1:res+1
    for j=1:res+1
        % Determine the U and W Matrices
             e = n-1;                                        
             U = zeros(1,e+1);                                              % Pre-allocated U matrix (sized accroding to the size of the input matrices)
             W = zeros(e+1,1);                                              % Pre-allocated W matrix (sized accroding to the size of the input matrices)         
           for exp = e:-1:0
             U(1,e+1-exp) =((i-1)/res)^exp;                                 % Based on equation provided in class
             W(e+1-exp,1) =((j-1)/res)^exp;                                 % Based on equation provided in class
           end
        % Coordinates of surface points
        Px(i,j) = U*N*Bx*NT*W;                                              % Thes equations are derived from literature                                         
        Py(i,j) = U*N*By*NT*W;
        Pz(i,j) = U*N*Bz*NT*W;

    end
end
end

