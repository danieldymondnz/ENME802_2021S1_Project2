function rotatedCoordinates = stlRotate(coordinatesToRotate, thetaX, thetaY, thetaZ)

    % Credit: Code derrived from Khan Academy
    % https://www.khanacademy.org/computing/computer-programming/programming-games-visualizations/programming-3d-shapes/a/rotating-3d-shapes

    % Convert angles in Degrees into Radians
    const = 2 * pi / 360;
    thetaX = thetaX * const;
    thetaY = thetaY * const;
    thetaZ = thetaZ * const;
    
    % Make a copy of the input coordinates
    rotatedCoordinates = coordinatesToRotate;
    
    % Rotate object on X axis
    if thetaX ~= 0
        rotatedCoordinates = rotateX(rotatedCoordinates, thetaX);
    end
       
    % Rotate object on Y axis
    if thetaY ~= 0
        rotatedCoordinates = rotateY(rotatedCoordinates, thetaY);
    end
    
    % Rotate object on Z axis
    if thetaZ ~= 0
        rotatedCoordinates = rotateZ(rotatedCoordinates, thetaZ);
    end

end

function rotatedCoordinates = rotateX(coordinatesToRotate, thetaX)

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

function rotatedCoordinates = rotateY(coordinatesToRotate, thetaY)

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

function rotatedCoordinates = rotateZ(coordinatesToRotate, thetaZ)

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
    