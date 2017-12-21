function [x_coord, y_coord] = Find_Center(bw_Ct_Shell)
%This function defines the center of the cortical slice as the point at
%which there is an equal number of pixels to the left and right as well as
%above and below this point

total_pix = sum(sum(bw_Ct_Shell));
num_pix = 0;
index = 1;
while num_pix <= total_pix / 2
    num_pix = num_pix + sum(bw_Ct_Shell(index, :));
    index = index + 1;
end
x_coord = index;

num_pix = 0;
index = 1;
while num_pix <= total_pix / 2
    num_pix = num_pix + sum(bw_Ct_Shell(:, index));
    index = index + 1;
end
y_coord = index;

end