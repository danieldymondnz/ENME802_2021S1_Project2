clear all 

B = [0 10 20 0;         %Position verxtor of each point (x,y)
    10 120 60 10;
    10 90 110 10; 
    0 40 30 0];

n = height(B);      %For U matrix
m = length(B);      %For W matrix *note that these do not need to be equal in reality 

via = 20;           %Divisions

lx = 0;             %Knowing coord. points of x - lower and upper values
ux = 10;

ly= 0;              %Knowing coord points of y - lower and upper values
uy = 10; 

% Parametric Relationship
t = 0:1/(via-1):1;

for j = 1:via
    for i=1:n
        U(j,i) = t(j)^(n-i);                 
    end 
end 

for j = 1:via
    for i = 1:m
        W(j,i) = t(j)^(m-i);
    end 
end 

% By definition, the Berstein basis functions for J and K for a surface is
% as follows 
for i = 1:n
    for j=1:n
        if (i+j-1<=n)
            N(i,j) = (factorial(n-1)/(factorial(j-1)*factorial(i-1)*factorial(n-i-j+1)))*((-1)^(n-i-j+1));
        else 
            N(i,j) = 0;
        end 
    end 
end 

for i = 1:m
    for j=1:m
        if (i+j-1<=m)
            M(i,j) = (factorial(m-1)/(factorial(j-1)*factorial(i-1)*factorial(m-i-j+1)))*((-1)^(m-i-j+1));
        else 
            M(i,j) = 0;
        end 
    end 
end

Z = U*N*B*M'*W'                 %General Bezier surface equation 
rx = lx:(ux-lx)/(via-1):ux;     %Taking the lowest and highest "boundaries" and dividing that section by the number of divisions
ry = ly:(uy-ly)/(via-1):uy;
[X,Y] = meshgrid(rx,ry)

figure 
mesh(X,Y,Z); hold on

X1 = lx:(ux-lx)/(n-1):ux;
Y1 = ly:(uy-ly)/(m-1):uy;
mesh(X1,Y1,B.'); hold on; hidden off
surf(X,Y,Z); xlabel('X-axis'); ylabel('Y-axis'); zlabel('Z-axis');
