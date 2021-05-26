function transformedSTL = stlTransform(stlToTransform, thetaX, thetaY, thetaZ, dX, dY, dZ, scale)

    % Credit: Rotation Code derrived from Khan Academy
    % https://www.khanacademy.org/computing/computer-programming/programming-games-visualizations/programming-3d-shapes/a/rotating-3d-shapes

    % Copy information from the STL
    stlPoints = stlToTransform.Points;
    stlConList = stlToTransform.ConnectivityList;
    
    % Perform rotations
    
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
    
    % Place onto positive plane
    stlPoints = autoPlaceCoordinates(stlPoints);
    
    % Translate if desired
    if (dX > 0 || dY > 0 || dZ > 0)
        stlPoints = translateCoordinates(stlPoints, dX, dY, dZ);
    end
    
    % Scale the object
    if (scale ~= 100)
        stlPoints(:,:) = stlPoints(:,:) * (scale / 100);
    end
    
    % Create new triangulation object to return 
    transformedSTL = triangulation(stlConList, stlPoints);

end

function coordinatesToTranslate = translateCoordinates(coordinatesToTranslate, dX, dY, dZ)

    coordinatesToTranslate(:,1) = coordinatesToTranslate(:,1) + dX;
    coordinatesToTranslate(:,2) = coordinatesToTranslate(:,2) + dY;
    coordinatesToTranslate(:,3) = coordinatesToTranslate(:,3) + dZ;

end

function coordinatesToAutoPlace = autoPlaceCoordinates(coordinatesToAutoPlace)

    % Check X,Y,Z Coordinates and fix model such that it sits on the plane
    for i = 1:3
        minOnAxis = min(coordinatesToAutoPlace(:,i));
        if minOnAxis ~= 0
            coordinatesToAutoPlace(:,i) = coordinatesToAutoPlace(:,i) - minOnAxis;
        end
    end

end

function coordinatesToRotate = rotateX(coordinatesToRotate, thetaX)
    
    % If the coordinate is a square angle (+/- 90, 180, 270), then just
    % invert rows and columns of matrix
    if mod(thetaX,90) == 0
        
        direct = thetaX/abs(thetaX);
        numOfNinetyDegRotations = thetaX / 90;
        
        for i = 1:abs(numOfNinetyDegRotations)
            
            coordinatesToRotate = [coordinatesToRotate(:,1), -1 * direct * coordinatesToRotate(:,3), direct * coordinatesToRotate(:,2)];
            
        end
    
    % Otherwise, use sine/cosine rotation rules
    else
        
        % Calculate the angle in radians and find sine/cosine components
        const = 2 * pi / 360;
        thetaX = thetaX * const;
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
    
end

function coordinatesToRotate = rotateY(coordinatesToRotate, thetaY)

    % If the coordinate is a square angle (+/- 90, 180, 270), then just
    % invert rows and columns of matrix
    if mod(thetaY,90) == 0
        
        direct = thetaY/abs(thetaX);
        numOfNinetyDegRotations = thetaY / 90;
        
        for i = 1:abs(numOfNinetyDegRotations)
            
            coordinatesToRotate = [direct * coordinatesToRotate(:,3), coordinatesToRotate(:,2), -1 * direct * coordinatesToRotate(:,1)];
            
        end
    
    % Otherwise, use sine/cosine rotation rules
    else

        const = 2 * pi / 360;
        thetaY = thetaY * const;
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
    
end

function coordinatesToRotate = rotateZ(coordinatesToRotate, thetaZ)
    
    % If the coordinate is a square angle (+/- 90, 180, 270), then just
    % invert rows and columns of matrix
    if mod(thetaZ,90) == 0
        
        direct = thetaZ/abs(thetaX);
        numOfNinetyDegRotations = thetaZ / 90;
        
        for i = 1:abs(numOfNinetyDegRotations)
            
            coordinatesToRotate = [-1 * direct *coordinatesToRotate(:,2), direct * coordinatesToRotate(:,1), coordinatesToRotate(:,3)];
            
        end
    
    % Otherwise, use sine/cosine rotation rules
    else

        const = 2 * pi / 360;
        thetaZ = thetaZ * const;
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
end
    