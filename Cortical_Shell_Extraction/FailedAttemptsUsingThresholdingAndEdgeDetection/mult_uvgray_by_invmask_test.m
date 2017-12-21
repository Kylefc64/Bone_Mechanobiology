function mult_uvgray_by_invmask_test()
% mult_uvgrays_by_invmasks('\\Biomech-10\i\Masks\Inverted_RTL06_R53_C8_masks\',
% '\\Biomech-10\i\Gray\OP\', 'RTL06_R53_C8_', 0, 1, '\\Biomech-10\i\uvgrays_by_invmasks\')

begin_index = 0;
end_index = 1;
slice_index = begin_index;
source_invmasks_dir = '\\Biomech-10\i\Masks\Inverted_RTL06_R53_C8_masks\';
spec_num = 'RTL06_R53_C8_';
source_uvgrays_dir = '\\Biomech-10\i\Gray\OP\';
target_dir = '\\Biomech-10\i\uvgrays_by_invmasks\';
voxel_input = 0.714;
voxel_output = 2.75;



while(slice_index <= end_index)
    %Create the inverted mask source directory name for this slice
    source_invmask_filename = [source_invmasks_dir, spec_num, 'masks_', num2str(slice_index, '%04d'), 'inverted.tif'];

    %Load the inverted mask matrix from the .tif file
    invmaskMatrix = imread(source_invmask_filename);

    %Create the uv grayscale mask source directory name for this slice
    source_uvgrays_filename = [source_uvgrays_dir, 'UV_', num2str(slice_index + 1, '%04d'), '_', spec_num, 'gray.tif'];

    %Load the uv grayscale matrix from the file
    uvgrayMatrix = imread(source_uvgrays_filename);

    %Rescale the uvgray image
    uvgrayMatrix = imresize(uvgrayMatrix, voxel_input/voxel_output ,'lanczos2');
    
    invmaskMatrix = im2uint16(invmaskMatrix);
    
    invmaskMatrix = invmaskMatrix/257;

    %multiply both matrices and story the result
    result = invmaskMatrix .* uvgrayMatrix;

    %Convert the logical result matrix to uint8
    %result = im2uint16(result);

    %Divide by 255 to create a matrix of 0s and 1s
    %result = result/255;

    %Set up the target filepath for this slice
    target_filename = [target_dir, spec_num, 'uvgrays_by_invmasks_', num2str(slice_index, '%04d'), '.tif'];

    %Write the result to file
    imwrite(result, target_filename);

    %Increment the slice index
    slice_index = slice_index + 1;
end