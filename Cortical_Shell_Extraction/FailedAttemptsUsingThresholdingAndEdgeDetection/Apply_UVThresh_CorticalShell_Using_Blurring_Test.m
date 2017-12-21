function Apply_UVThresh_CorticalShell_Using_Blurring_Test()
%http://www.mathworks.com/help/images/examples/detecting-a-cell-using-image-segmentation.html
%http://stackoverflow.com/questions/15823507/removing-outliers-from-a-grey-scale-image
%http://stackoverflow.com/users/1214731/tmpearce
%http://www.mathworks.com/help/images/ref/bwareaopen.html
%http://www.mathworks.com/help/images/ref/imfill.html#buo3hpj-1
%http://www.mathworks.com/help/images/ref/imfill.html
%http://www.mathworks.com/help/images/ref/edge.html#References

%Explicit values for testing
spec_num = 'RTL06_R53_C8_';
begin_index = 750;
end_index = 750;
slice_index = begin_index;
source_dir = '\\Biomech-10\i\uvgrays_by_invmasks\';
%source_dir = '\\Biomech-10\i\Gray\OP\';
target_dir = '\\Biomech-10\i\Thresh_Applied_CorticalShell_UV\';
strel_size = 10;
se = strel('disk', strel_size); %structuring element
scale = 1000;

while(slice_index <= end_index)
    %Set up the path to the source image
    source_filename = [source_dir, spec_num, 'uvgrays_by_invmasks_', num2str(slice_index, '%04d'), '.tif'];
    %source_filename = [source_dir, 'UV_', num2str(slice_index, '%04d_'), spec_num, 'gray.tif'];
    
    %Read the source image
    original_gray = imread(source_filename);
    
    resampled_filename = ['\\Biomech-10\i\Thresh_Resampled\', 'UV_', num2str(slice_index, '%04d_'), spec_num, 'thresh.tif'];
    resampled = imread(resampled_filename);
    
    %{
    Method5
    
    window1 = original_gray(200:800, 200:800);
    window_thresh1 = graythresh(nonzeros(window1));
    bw_thresh_image1 = im2bw(original_gray, window_thresh1);
    closed_thresh1 = imclose(bw_thresh_image1, se);
    filled_thresh1 = imfill(closed_thresh1, 'holes');
    new_gray1 = uint16(filled_thresh1) .* original_gray;
    imtool(new_gray1);
    

    window2 = new_gray1(200:800, 200:800);
    window_thresh2 = graythresh(nonzeros(window2));
    bw_thresh_image2 = im2bw(new_gray1, window_thresh2);
    se = strel('disk', 20);
    closed_thresh2 = imclose(bw_thresh_image2, se);
    filled_thresh2 = imfill(closed_thresh2, 'holes');
    new_gray2 = uint16(filled_thresh2) .* original_gray;
    imtool(new_gray2);
    
    window3 = new_gray2(200:800, 200:800);
    window_thresh3 = graythresh(nonzeros(window3));
    bw_thresh_image3 = im2bw(new_gray2, window_thresh3);
    se = strel('disk', 30);
    closed_thresh3 = imclose(bw_thresh_image3, se);
    filled_thresh3 = imfill(closed_thresh3, 'holes');
    new_gray3 = uint16(filled_thresh3) .* original_gray;
    imtool(new_gray3);
    
    filtered1 = imfilter(new_gray3, fspecial('average', 5));
    edge1 = edge(filtered1, 'Sobel');
    se = strel('disk', 5);
    edge_closed1 = imclose(edge1, se);
    imtool(edge_closed1);
    
    window4 = new_gray3(200:800, 200:800);
    window_thresh4 = graythresh(nonzeros(window4));
    bw_thresh_image4 = im2bw(new_gray3, window_thresh4);
    se = strel('disk', 40);
    closed_thresh4 = imclose(bw_thresh_image4, se);
    filled_thresh4 = imfill(closed_thresh4, 'holes');
    new_gray4 = uint16(filled_thresh4) .* original_gray;
    imtool(new_gray4);
    
    window5 = new_gray4(200:800, 200:800);
    window_thresh5 = graythresh(nonzeros(window5));
    bw_thresh_image5 = im2bw(new_gray4, window_thresh5);
    se = strel('disk', 50);
    closed_thresh5 = imclose(bw_thresh_image5, se);
    filled_thresh5 = imfill(closed_thresh5, 'holes');
    new_gray5 = uint16(filled_thresh5) .* original_gray;
    imtool(new_gray5);
    
    window6 = new_gray5(200:800, 200:800);
    window_thresh6 = graythresh(nonzeros(window6));
    bw_thresh_image6 = im2bw(new_gray5, window_thresh6);
    se = strel('disk', 50);
    closed_thresh6 = imclose(bw_thresh_image6, se);
    filled_thresh6 = imfill(closed_thresh6, 'holes');
    new_gray6 = uint16(filled_thresh6) .* original_gray;
    imtool(new_gray6);
    
    window7 = new_gray6(200:800, 200:800);
    window_thresh7 = graythresh(nonzeros(window7));
    bw_thresh_image7 = im2bw(new_gray6, window_thresh7);
    se = strel('disk', 50);
    closed_thresh7 = imclose(bw_thresh_image7, se);
    filled_thresh7 = imfill(closed_thresh7, 'holes');
    new_gray7 = uint16(filled_thresh7) .* original_gray;
    imtool(new_gray7);
    %}
    
    %{
    Method 4
    
    CC = bwconncomp(resampled);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    largest_connected1 = zeros(size(resampled));
    largest_connected1(CC.PixelIdxList{idx}) = 1;
    
    new_gray1 = original_gray .* uint16(largest_connected1);
    
    %gray_window1 = new_gray1(200:800, 200:800);
    %thresh1 = graythresh(nonzeros(new_gray1));
    %gray_threshed1 = new_gray1 > thresh1;
    filtered1 = imfilter(new_gray1, fspecial('average', 5));
    edge1 = edge(filtered1, 'Sobel');
       
    closed_edge1 = imclose(edge1, se);
    inv_closed_edge1 = ~closed_edge1;
    
    bin_mask1 = inv_closed_edge1 .* largest_connected1;
    
    CC = bwconncomp(bin_mask1);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    largest_connected2 = zeros(size(bin_mask1));
    largest_connected2(CC.PixelIdxList{idx}) = 1;
    
    filled1 = imfill(largest_connected2, 'holes');
    se = strel('disk', 20);
    closed1 = imclose(filled1, se);
    
    imtool(closed1);
    %}
    
    %{
    Method 1
    [~, threshold] = edge(image, 'sobel');
    fudgeFactor = 0.5;
    BWs = edge(image, 'sobel', threshold * fudgeFactor);
    
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    BWsdil = imdilate(BWs, [se90 se0]);
    
    BWdfill = imfill(BWsdil, 'holes');
    
    seD = strel('diamond', 1);
    %BWfinal = imerode(BWfill, seD);
    BWfinal = imerode(BWfill, seD);
    %}
    
    %{
    %Method 2
    scaled_image = image / scale;
    scaled_image = scaled_image.*scaled_image.*scaled_image;
    thresh_level = graythresh(nonzeros(scaled_image));
    bw = im2bw(scaled_image, thresh_level);
    bw = imclose(bw, se);
    %bw = imopen(bw, se);
    
    bw = bwareaopen(bw, 200000);
    
    imtool(bw);
    
    %The following code did nothing to affect the binary image
    CC = bwconncomp(bw);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    A = zeros(size(bw));
    A(CC.PixelIdxList{idx}) = 1;
    %}
    
    %{
    Method 3 (See notes 6/09/16)
    filtered1 = imfilter(image, fspecial('average', 5));
    imtool(filtered1);
    
    window1 = image(200:800, 200:800);
    window_thresh1 = graythresh(nonzeros(window1));
    bw_thresh_image1 = im2bw(image, window_thresh1);
    bw_thresh_image1 = (uint16(bw_thresh_image1));
    bw_thresh_image1 = imclose(bw_thresh_image1, se);
    bw_thresh_image1 = imfill(bw_thresh_image1, 'holes');%%%
    new_gray1 = bw_thresh_image1 .* image;
    %imtool(new_gray1);
    
    %new_gray1 = imfilter(new_gray1, fspecial('average', 10));
    window2 = new_gray1(200:800, 200:800);
    window_thresh2 = graythresh(nonzeros(window2));
    bw_thresh_image2 = im2bw(new_gray1, window_thresh2);
    bw_thresh_image2 = (uint16(bw_thresh_image2));
    bw_thresh_image2 = imclose(bw_thresh_image2, se);
    bw_thresh_image2 = imfill(bw_thresh_image2, 'holes');%%%
    
    %filled = imfill(new_gray2, 'holes');
    filled = bw_thresh_image2 .* new_gray1;
    %se = strel('disk', 10);
    %imtool(filled);
    
    
    %edge_gaussian1 = edge(gaussian1, 'Sobel');
    %imtool(edge_gaussian1);
    %closed_edge_gaussian1 = imclose(edge_gaussian1, se);
    %imtool(closed_edge_gaussian1);
    %mean = mean2(image);
    %std = std2(image);
    %bw_open1 = bwareaopen(closed_edge_gaussian1, mean - std);
    %filled1 = imfill(closed_edge_gaussian1, 'holes');
    
    %imtool(filled1);
    
    CC = bwconncomp(filled);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    new_img = zeros(size(filled));
    new_img(CC.PixelIdxList{idx}) = 1;
    
    %imtool(new_img);
    
    
    imtool(original_img);
    imtool(uint16(new_img) .* original_img);
    
    resampled_filename = ['\\Biomech-10\i\Thresh_Resampled\', 'UV_', num2str(slice_index, '%04d_'), spec_num, 'thresh.tif'];
    resampled1 = imread(resampled_filename);
    
    final_img1 = resampled1 .* new_img;
    %imtool(final_img1);
    
    CC = bwconncomp(final_img1);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    new_img2 = zeros(size(final_img1));
    new_img2(CC.PixelIdxList{idx}) = 1;
    
    se = strel('disk', 10);
    final_img2 = imclose(imfill(uint16(new_img2), 'holes'), se) .* original_img;
    imtool(final_img2);
   
    %}
    
    
    %average = imfilter(image, fspecial('average', [50, 50]));
    %thresh_level = graythresh(nonzeros(average));
    %thresh_val = max(max(average))*thresh_level + 3*std2(nonzeros(average));
    %bw = average > thresh_val;
    %imtool(bw);
    
    %%scaled_image = image / scale;
    %%scaled_image = scaled_image.*scaled_image.*scaled_image;
    %%scaled_image = imfilter(scaled_image, fspecial('gaussian', [50, 50], 5));
    %imtool(smooth_scaled);
    
    %imtool(image);
    
    %smooth = imfilter(image, fspecial('gaussian', [50, 50], 5));
    %thresh_level = graythresh(nonzeros(image));
    %smooth = imfilter(image, fspecial('disk', 100));
    %unsharp = imfilter(image, fspecial('unsharp'));
    %imtool(unsharp);
    %sharp = image - unsharp;
    %imtool(smooth);
    %%std_matrix = std2(nonzeros(scaled_image));
    %%thresh_val = graythresh(nonzeros(scaled_image))*(max(max(scaled_image))) + 1.10*std_matrix;
    %%bw = scaled_image > thresh_val;
    %bw = im2bw(scaled_image, thresh_level);
    %%imtool(bw);
    
    %Determine the threshold level for this slice
    %thresh_level = graythresh(nonzeros(image));
    %std_matrix = std2(nonzeros(image));
    %thresh_val = graythresh(nonzeros(image))*(max(max(image))) + 2.57*std_matrix;
    %thresh_val = graythresh(nonzeros(image))*(max(max(image))) + 2.30*std_matrix;
    

    %Create an image of only values greater than the threshold level
    %thresh_image = image > thresh_val;
    %thresh_image = image > thresh_level;
    %thresh_image = im2bw(image, thresh_level);
    
    %Perform image closing on the image
    %%bw = imclose(bw, se);
    
    %Perform image opening on the image
    %%bw = imopen(bw, se);
    
    %Display the image
    %imtool(bw);
    %imtool(filled_image);

    %Set up the path to the target file
    %%target_filename = [target_dir, spec_num, 'UVThresh_CorticalShell_', num2str(slice_index, '%04d'), '.tif'];

    %Write the result to file
    %%imwrite(thresh_image, target_filename);
    
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

%}

%{
imtool(closed1);
se = strel('disk', 2);
closed2 = imclose(thresh_crop, se);
imtool(closed2);
sobel = edge(image, 'Sobel');
imtool(sobel);
imtool(edge(image, 'Roberts'));
imtool(edge(image, 'Prewitt'));
imtool(sobel);
closed3 = imclose(sobel, se);
imtool(closed3);
open_closed3 = bwareaopen(closed3, 1000);
imtool(open_closed3);
se = strel('disk', 10);
closed4 = imclose(sobel);
??? Error using ==> iptchecknargin at 57
Function IMCLOSE expected at least 2 input arguments
but was called instead with 1 input argument.

Error in ==> imclose>ParseInputs at 58
iptchecknargin(2,2,nargin,mfilename);

Error in ==> imclose at 40
[A,SE,pre_pack] = ParseInputs(varargin{:});
 
closed4 = imclose(sobel, se);
imtool(closed4);
open_closed4 = bwareaopen(closed4, 1000);
imtool(open_closed4);
filled4 = imfill(open_closed4);
Warning: Image is too big to fit on screen; displaying at 33% 
> In imuitools\private\initSize at 73
  In imshow at 262
  In imfill>get_locations_interactively at 328
  In imfill>parse_inputs at 269
  In imfill at 124
??? Error using ==> getpts at 179
Interruption during mouse point selection.

Error in ==> imfill>get_locations_interactively at 329
[xi,yi] = getpts;

Error in ==> imfill>parse_inputs at 269
    locations = get_locations_interactively(IM);

Error in ==> imfill at 124
[I,locations,conn,do_fillholes] = parse_inputs(varargin{:});
 
filled4 = imfill(open_closed4, 'holes');
imtool(filled4);
%}
