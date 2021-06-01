function output = nanCleanUp(input)
    output = input(~isnan(input(:,3)),1:4);
end