function [] = cutterpath(N,NT,Bx,By,Bz,resc,resr)
for i=1:resc+1
    for j=1:resr+1
        
        U = [((i-1)/resc)^4 ((i-1)/resc)^3 ((i-1)/resc)^2 ((i-1)/resc) 1];
        W = [((j-1)/resr)^4; ((j-1)/resr)^3; ((j-1)/resr)^2; ((j-1)/resr); 1];
        
              Px(i,j) = U*N*Bx*NT*W;
              Py(i,j) = U*N*By*NT*W;
              Pz(i,j) = U*N*Bz*NT*W;
    end 
end 

