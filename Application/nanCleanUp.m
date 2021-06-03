function output = nanCleanUp(input)
    output = input(~isnan(input(:,3)),:);
end