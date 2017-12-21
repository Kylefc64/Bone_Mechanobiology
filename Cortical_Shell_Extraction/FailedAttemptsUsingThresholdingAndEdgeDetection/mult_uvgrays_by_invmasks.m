function mult_uvgrays_by_invmasks(source_invmasks_dir, source_uvgrays_dir, spec_num, begin_slice, end_slice, target_dir)
%source_inv_masks_dir is the directory where the inverted masks are located
%source_uvgrays_dir is the directory where the uv grayscale images are located
%spec_num is the specimen number being processed
%begin_slice is the first in the range of masks to be processed
%end_slice is the last in the range of masks to be processed
%(Note: an inverted mask with index i corresponds with uv grayscale image of index i + 1)
%target_dir is the directory where the results are saved after being processed
%Example run:
%>> mult_uvgrays_by_invmasks('\\Biomech-10\i\Masks\Inverted_RTL06_R53_C8_masks\', '\\Biomech-10\i\Gray\OP\', 'RTL06_R53_C8_', 200, 1000, '\\Biomech-10\i\uvgrays_by_invmasks\')

voxel_input = 0.714;
voxel_output = 2.75;

%slice_index is used to iterate through the range of slices for this specimen
slice_index = begin_slice;

while(slice_index <= end_slice)

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
    
    %Convert the inverted mask matrix to the same class as the uv grayscale image
    invmaskMatrix = uint16(invmaskMatrix);
    
    %Divide by 257 to create a matrix of solely 0s and 1s
    %invmaskMatrix = invmaskMatrix/257;

    %multiply both matrices and story the result
    result = invmaskMatrix .* uvgrayMatrix;

    %Set up the target filepath for this slice
    target_filename = [target_dir, spec_num, 'uvgrays_by_invmasks_', num2str(slice_index, '%04d'), '.tif'];

    %Write the result to file
    imwrite(result, target_filename);

    %Increment the slice index
    slice_index = slice_index + 1;
end
