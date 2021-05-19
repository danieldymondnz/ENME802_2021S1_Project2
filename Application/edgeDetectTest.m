function edgeDetectTest(op)
% Find unique z axis'
[C,ia,~] = unique(op(:,3));
for i=1:height(ia)-1
    X=op(ia(i):ia(i+1)-1,1);
    Y=op(ia(i):ia(i+1)-1,2);
    
    [C2,ia2,~]=unique([X Y],'rows');

    for j=1:height(ia2)
        % append unique stuff back
        opUnique(j,1) = X(ia2(j),1);
        opUnique(j,2) = Y(ia2(j),1);
    end

    X = opUnique(:,1);
    Y = opUnique(:,2);

%     XCenter = mean(X);
%     YCenter = mean(Y);
%     angles = atan2d((Y-YCenter) , (X-XCenter));
% 
%     [~, sortIndexes] = sort(angles);
%     X = X(sortIndexes);  % Reorder x and y with the new sort order.
%     Y = Y(sortIndexes);
%     
    X(end+1,1) = X(1);
    Y(end+1,1) = Y(1);
    Z = zeros(height(X));
    Z(:) = C(i);

    hold on
    plot3(X,Y,Z);
    
    % Do last layer
    if i == height(ia)-1
        X = op(ia(end):height(op),1);
        Y = op(ia(end):height(op),2);
        
        [C2,ia2,~]=unique([X Y],'rows');
        opUnique = [];
        for j=1:height(ia2)
            % append unique stuff back
            opUnique(j,1) = X(ia2(j),1);
            opUnique(j,2) = Y(ia2(j),1);
        end
        
        X = opUnique(:,1);
        Y = opUnique(:,2);

%         XCenter = mean(X);
%         YCenter = mean(Y);
%         angles = atan2d((Y-YCenter) , (X-XCenter));
% 
%         ~, sortIndexes] = sort(angles);
%         X = X(sortIndexes);  % Reorder x and y with the new sort order.
%         Y = Y(sortIndexes);[

        X(end+1,1) = X(1);
        Y(end+1,1) = Y(1);
        Z = zeros(height(X));
        Z(:) = C(end);
        
        hold on
        plot3(X,Y,Z);

        
    end

        
        
    end




end