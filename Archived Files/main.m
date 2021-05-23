function main(filePath,sliceType,sliceThickness)
% clear;

try
    stl = importSTL(filePath);
catch exception
    throw(exception)
end

% Check if sliceType input is Flat or Curved.
if strcmp(sliceType,"Flat Uniform Slice")
    % Call Uniform Slice function
    stlSlicedObj = FlatUniformSliceGenerator(stl, sliceThickness);
else
    
end

    
end
