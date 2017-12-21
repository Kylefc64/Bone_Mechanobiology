function mult_grays_by_inv_masks(source_masks_dir, source_grays_dir, spec_num, num_slices, target_dir)

source_mask_filename = [source_masks_dir, spec_num, 'masks_', num2str(slice_num, '%04d'), 'inverted.tif'];

maskMatrix = imread(source_mask_filename);

source_grays_filename = ['UV_', num2str(slice_num + 1, '%04d'), '_', spec_num, 'gray.tif'];

grayMatrix