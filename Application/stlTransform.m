function transformedSTL = stlTransform(stlToTransform, thetaX, thetaY, thetaZ)

    % Credit: Code derrived from Khan Academy
    % https://www.khanacademy.org/computing/computer-programming/programming-games-visualizations/programming-3d-shapes/a/rotating-3d-shapes

    % Copy information from the STL
    stlPoints = stlToTransform.Points;
    stlConList = stlToTransform.ConnectivityList;
    
    % Convert angles in Degrees into Radians
    const = 2 * pi / 360;
    thetaX = thetaX * const;
    thetaY = thetaY * const;
    thetaZ = thetaZ * const;
    
    % Rotate object on X axis
    if thetaX ~= 0
        stlPoints = rotateX(stlPoints, thetaX);
    end
       
    % Rotate object on Y axis
    if thetaY ~= 0
        stlPoints = rotateY(stlPoints, thetaY);
    end
    
    % Rotate object on Z axis
    if thetaZ ~= 0
        stlPoints = rotateZ(stlPoints, thetaZ);
    end
    
    % Check X,Y,Z Coordinates and fix model such that it sits on the plane
    for i = 1:3
        minOnAxis = min(stlPoints(:,i));
        if minOnAxis ~= 0
            stlPoints(:,i) = stlPoints(:,i) - minOnAxis;
        end
    end
    
    % Create new triangulation object to return 
    transformedSTL = triangulation(stlConList, stlPoints);

end

function coordinatesToRotate = rotateX(coordinatesToRotate, thetaX)

    sinTheta = sin(thetaX);
    cosTheta = cos(thetaX);
    
    for point = 1:height(coordinatesToRotate)
        
        % Extract Points
        currY = coordinatesToRotate(point, 2);
        currZ = coordinatesToRotate(point, 3);
        
        % Modify Y
        coordinatesToRotate(point, 2) = currY * cosTheta - currZ * sinTheta;
        
        % Modify Z
        coordinatesToRotate(point, 3) = currZ * cosTheta + currY * sinTheta;
        
    end
    
end

function coordinatesToRotate = rotateY(coordinatesToRotate, thetaY)

    sinTheta = sin(thetaY);
    cosTheta = cos(thetaY);
    
    for point = 1:height(coordinatesToRotate)
        
        % Extract Points
        currX = coordinatesToRotate(point, 1);
        currZ = coordinatesToRotate(point, 3);
        
        % Modify X
        coordinatesToRotate(point, 1) = currX * cosTheta + currZ * sinTheta;
        
        % Modify Z
        coordinatesToRotate(point, 3) = currZ * cosTheta - currX * sinTheta;
        
    end
    
end

function coordinatesToRotate = rotateZ(coordinatesToRotate, thetaZ)

    sinTheta = sin(thetaZ);
    cosTheta = cos(thetaZ);
    
    for point = 1:height(coordinatesToRotate)
        
        % Extract Points
        currX = coordinatesToRotate(point, 1);
        currY = coordinatesToRotate(point, 2);
        
        % Modify X
        coordinatesToRotate(point, 1) = currX * cosTheta - currY * sinTheta;
        
        % Modify Y
        coordinatesToRotate(point, 2) = currY * cosTheta + currX * sinTheta;
        
    end
    
end
    