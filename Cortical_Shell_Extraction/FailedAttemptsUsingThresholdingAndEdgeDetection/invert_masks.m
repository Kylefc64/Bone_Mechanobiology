function invert_masks(source_spec_dir, spec_num, num_slices, target_spec_dir)
%source_spec_dir is the source directory containing each of the the 
%individual 2d slices of this specimen
%spec_num is the specimen number
%num_slices is the number of 2d slices for this specimen
%target_spec_dir is the target location of all of the inverted masks
%Example run: 
%>> invert_masks('\\Biomech-10\i\Masks\', 'RTL06_R53_C8_', 1199,'\\Biomech-10\i\Masks\Inverted_RTL06_R53_C8_masks\')

slice_num = 0; %the number of the 2d slice of this specimen

while(slice_num < num_slices)
    %Create the mask source directory name
    % Ex: '\\Biomech-10\i\Masks\RTL06_R53_C8_masks_0000.tif'];
    source_filename = [source_spec_dir, spec_num, 'masks_', num2str(slice_num, '%04d'), '.tif'];

    %Load the matrix from the .tif file
    imageMatrix = imread(source_filename);

    %Invert the mask
    imageMatrix = ~imageMatrix;

    %Convert the logical mask matrix to uint8
    imageMatrix = im2uint8(imageMatrix);

    %Divide by 255 to create a matrix of 0s and 1s
    imageMatrix = imageMatrix/255;

    %Set up the target directory for the inverted mask
    %Ex: '\\Biomech-10\i\Masks\RTL06_R53_C8_masks_0000_inverted.tif';
    target_filename = [target_spec_dir, spec_num, 'masks_', num2str(slice_num, '%04d'), 'inverted.tif'];

    %Write the inverted mask to file
    imwrite(imageMatrix, target_filename);
    slice_num = slice_num + 1;
end