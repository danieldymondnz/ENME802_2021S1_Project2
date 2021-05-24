% Clear the Workspace to avoid any conflicts with Workspace data
% Clear Console
clear all;
clc;

% Pre-define the shape of the bezier curve in the X, Y, and Z directions
Bx = [  0 15 30 45 60;
        0 15 30 45 60;
        0 15 30 45 60;
        0 15 30 45 60;
        0 15 30 45 60   ];

By = [  00 00 00 00 00;
        15 15 15 15 15;
        30 30 30 30 30;
        45 45 45 45 45;
        60 60 60 60 60  ];

Bz = [0 25 50 25 0;
   25 65 400 65 25;
   50 200 750 200 50;
   25 65 400 65 25;
   0 25 50 25 0];

N = [1 -4 6 -4 1; -4 12 -12 4 0; 6 -12 6 0 0; -4 4 0 0 0;1 0 0 0 0];
NT = transpose(N);

% Define user-configurable parameters
res     = input('Enter resolution of the Bezier surface: No. of points in each parametric direction:');
resc    = input('Number of points on each cutter path:');
resr    = input('Enter Number of Cutter paths:');

% Main routine (calculate points for each coordinate)

% i,j track the resolution in each of the x and y planes
for i = 1:res+1
    
    for j=1:res+1
      
        % Determine the U and W Matrices
        U = [((i-1)/res)^4 ((i-1)/res)^3 ((i-1)/res)^2 ((i-1)/res) 1];
        W = [((j-1)/res)^4; ((j-1)/res)^3; ((j-1)/res)^2; ((j-1)/res); 1];
        
        % Coordinates of surface points 
        Px(i,j) = U*N*Bx*NT*W;
        Py(i,j) = U*N*By*NT*W;
        Pz(i,j) = U*N*Bz*NT*W;

    end 
    
end

% Display surface and control points on screen 
figure(1)   
mesh(Px,Py,Pz);
shading interp;
title('Bezier Surface');
grid on
xlabel('X-axis');ylabel('Y-axis');zlabel('Z-axis');

% Display the paths on-screen
figure(2) 
plot3(Px, Py, Pz)
hold on 
grid on
title('CNC Cutter paths');
xlabel('X-Axis'); ylabel('Y-Axis'); zlabel('Z-Axis')

% Display the 'cutter-paths' on-screen
cutterpath(N,NT,Bx,By,Bz,resc,resr)