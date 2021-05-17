function drawSTL(X,Y,Z,connectivity)
    for i=1:height(connectivity)
    P = [X(connectivity(i,1));X(connectivity(i,2));X(connectivity(i,3))];
    Q = [Y(connectivity(i,1));Y(connectivity(i,2));Y(connectivity(i,3))];
    R = [Z(connectivity(i,1));Z(connectivity(i,2));Z(connectivity(i,3))];
    figure(1)
    patch(P,Q,R,'g')
    hold on;
    end
end