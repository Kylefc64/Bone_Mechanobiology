function Apply_UVThresh_CorticalShell_Test()

%Explicit values for testing
spec_num = 'RTL06_R53_C8_';
begin_index = 500;
end_index = 500;
slice_index = begin_index;
source_dir = '\\Biomech-10\i\uvgrays_by_invmasks\';
target_dir = '\\Biomech-10\i\Thresh_Applied_CorticalShell_UV\';

while(slice_index <= end_index)
    %Set up the path to the source image
    source_filename = [source_dir, spec_num, 'uvgrays_by_invmasks_', num2str(slice_index, '%04d'), '.tif'];
    
    %Read the source image
    image = imread(source_filename);
    
    %Determine the threshold level for this slice
    %thresh_level = graythresh(nonzeros(image));
    std_matrix = std2(nonzeros(image));
    %thresh_val = graythresh(nonzeros(image))*(max(max(image))) + 2.57*std_matrix;
    thresh_val = graythresh(nonzeros(image))*(max(max(image))) + 2.30*std_matrix;
    

    %Create an image of only values greater than the threshold level
    thresh_image = image > thresh_val;
    %thresh_image = image > thresh_level;
    %thresh_image = im2bw(image, thresh_level);
    
    %Perform image closing on the image
    se = strel('disk', 6);
    thresh_image = imclose(thresh_image, se);
    
    %Perform image opening on the image
    thresh_image = imopen(thresh_image, se);
    
    %Display the image
    imtool(thresh_image);
    %imtool(filled_image);

    %Set up the path to the target file
    target_filename = [target_dir, spec_num, 'UVThresh_CorticalShell_', num2str(slice_index, '%04d'), '.tif'];

    %Write the result to file
    imwrite(thresh_image, target_filename);
    
    %Increment slice number
    slice_index = slice_index + 1;
end

%{
Unused functions (could be useful later)

    %bw = imfill(image);
    %imtool(bw);

    %thresh_image = imfill(thresh_image, 'holes');

    %Find edges
    %bw = edge(image, 'Roberts');
    %bw = edge(image, 'Prewitt');
    %bw = edge(image, 'Sobel');
    
    %Fill in areas bounded by edges
    %filled_image = imfill(bw, 'holes');

