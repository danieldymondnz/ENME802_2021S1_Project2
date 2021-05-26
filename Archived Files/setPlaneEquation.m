function planeEquation = setPlaneEquation(xCoefficient,xModifier,yCoefficient,yModifier,zCoefficient,zModifier)
syms x y z;

planeEquation = xCoefficient*x^xModifier + yCoefficient*y^yModifier + zCoefficient*z^zModifier;
end