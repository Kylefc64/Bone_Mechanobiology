function cortical_shell_algorithm2()

spec_num = 'RTL06_R53_C8_';
begin_index = 750;
end_index = 750;
strel_size = 200; %custom size for each slice(?)
pixel_thresh = 2000; %custom threshold for each slice(?)
slice_index = begin_index;
source_dir = '\\Biomech-10\i\Gray\OP\';
target_dir = '\\Biomech-10\i\CorticalShell_UV\';
coarsening_factor = 0.05;

while(slice_index <= end_index)
    %Set up the path to the source image
    source_filename = [source_dir, 'UV_', num2str(slice_index, '%04d_'), spec_num, 'gray.tif'];
    %source_filename = '\\Biomech-10\i\randomSlicesFromRats\UV_1135_RTL06_R65_C8_gray.tif';
    
    %Read the source image
    original_gray1 = imread(source_filename);
    
    %Coarsen the original grayscale image
    coarsened1 = imresize(original_gray1, coarsening_factor);%0.05
    
    %Apply edge detection to the coarsened grayscale image
    edge1 = edge(coarsened1, 'sobel');
    
    %Create a binary mask of the entire coarsened image
    bin1 = coarsened1 > 0;
    
    %Erode the mask by a couple of pixels
    eroded_mask1 = imerode(bin1, strel('disk', 2));
    
    %Apply the eroded mask to the set of edge points to remove edge points
    %detected near the border of the image
    cleaned_edge1 = edge1 .* eroded_mask1;
    
    %First, find dimensions of the original grayscale image
    dim_original_gray1 = size(original_gray1);
    %Then, resample the mask to its original size  
    resampled1 = imresize(cleaned_edge1, [dim_original_gray1(1), dim_original_gray1(2)]);
    
    %Eliminate the gray effect of resampling a binary image
    bin2 = resampled1 > 0.5;
    
    %Remove small clusters of pixels
    %mean = mean2(original_gray1);
    %sigma = std2(original_gray1);
    %std_scalar = 1.0; %custom constant for each slice
    %pixel_thresh = round(mean - std_scalar*sigma); %pixel threshold
    
    %area_open1 = bwareaopen(bin2, pixel_thresh);
    %area_open1 = bin2; %%%%
    area_open1 = bwareaopen(bin2, pixel_thresh);%(2000)%numPix should be a custom value for each slice
                                        %(perhaps remove the 20% smallest clusters)                               
    
    %Close gaps between edge clusters to prep image for filling
    %strel_size = 250; %custom size for each slice
    closed1 = imclose(area_open1, strel('disk', strel_size));%200(750)%perhaps customize the disk radius to each slice
    
    %Find the largest connected component and discard other components
    %http://www.mathworks.com/matlabcentral/answers/30693-find-the-3-maximum-elements-and-their-index
    %http://www.mathworks.com/matlabcentral/newsreader/view_thread/274267
    CC = bwconncomp(closed1);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    largest_conn1 = zeros(size(closed1));
    largest_conn1(CC.PixelIdxList{idx}) = 1;
    
    %Fill the interior of the largest connected component    
    filled1 = imfill(largest_conn1, 'holes');
    filled1 = uint16(filled1);
    
    %Create a grayscale image containing possible unwanted connected regions
    %around the outer border of the cortical shell
    inter_img1 = filled1 .* original_gray1; %(intermediate grayscale image)
    
    %imtool(inter_img1);%%%%
    
    
    
    %Applying thresholding appears to remove too much bone from the image
    %Leaving too much surrounding plastic seems to be a better alternative
    %Apply thresholding to remove some unwanted lighter (plastic) regions
    thresh_level1 = graythresh(nonzeros(inter_img1));
    thresh_img1 = im2bw(inter_img1, thresh_level1);
    
    %Close the image to avoid losing pixels that were separated from
    %the largest connected component via thresholding
    closed2 = imclose(thresh_img1, strel('disk', 2));%may have to interpolate disk size per slice
    
    %Eliminate all pixels not connected to the largest component
    CC = bwconncomp(closed2);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    largest_conn2 = zeros(size(closed2));
    largest_conn2(CC.PixelIdxList{idx}) = 1;
    
    %fill in all holes on the inside of the cortical shell
    filled2 = imfill(largest_conn2, 'holes');
    
    %Multiply the mask by the resampled grayscale image to create the final
    %grayscale image
    filled2 = uint16(filled2);
    final_img1 = filled2 .* original_gray1;
    
    imtool(final_img1);%%%%
    
    
    
    slice_index = slice_index + 1;
end