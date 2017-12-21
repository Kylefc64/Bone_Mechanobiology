%Created by Kyle Cripps
function dynamic_plot_resize2()

%The dimensions of the plot will be tested every [test_interval] seconds
test_interval = 0.5;

%X and Y axes inputs
x = [1,2,3,4,5,6,7,8,9];
y = [9,8,7,6,5,4,3,2,1];

%Plot the X and Y axes and store the plot as fig1
fig1 = plot(x,y);

%Get the initial dimensions of the plot
pos1 = get(gcf, 'Position');
width1 = pos1(3);
height1 = pos1(4);

%Print the dimensions of the plot
fprintf('%d\n', width1);
fprintf('%d\n', height1);

while(true)
    %Wait this many seconds for something to happen
    pause(test_interval);
    
    %Get the current dimensions of the plot
    pos = get(gcf, 'Position');
    width = pos(3);
    height = pos(4);
    
    %If the current dimensions (of pos) are different than the dimensions of pos1,
    %print the new dimensions of the plot and do something
    if(width ~= width1 || height ~= height1)
        fprintf('Plot has been resized\n');
        fprintf('%d\n', width);
        fprintf('%d\n', height);
        
        %Do something%%%%%%%%%%%%%%%%
        
        %Assign pos to pos1
        width1 = width;
        height1 = height;
    end
    
    %Exit the loop if the exit button on the plot has been clicked
    %%%%%%%%
    %if(condition is true)
        %break;
    %end
    %%%%%%%
    
end