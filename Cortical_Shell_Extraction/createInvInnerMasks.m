function createInvInnerMasks()

innerMaskDir = '\\Biomech-11\n\RTL06_R53_C8_Processed\Tiled\Masks\';
innerMaskName = 'RTL06_R53_C8_masks_';

imageDir = '\\Biomech-11\n\RTL06_R53_C8_Processed\Tiled\Gray\OP\';
imageName = 'RTL06_R53_C8_gray';

targetDir = '\\Biomech-10\i\Pictures_For_Presenting\';
targetName = 'RTL06_R53_C8_inv_inner_mask_';

beginIndex = 500;
endIndex = 500;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sliceIndex = beginIndex;

while(sliceIndex <= endIndex)
    %read mask and corresponding uv grayscale image into memory
    innerMaskFilePath = [innerMaskDir, innerMaskName, num2str(sliceIndex, '%04d'), '.tif'];
    innerMask = imread(innerMaskFilePath);
    
    imageFilePath = [imageDir, 'UV_', num2str(sliceIndex + 1, '%04d_'), imageName, '.tif'];
    uv_image = imread(imageFilePath);
    
    %invert the inner mask
    innerMask = ~innerMask;
    
    %get the dimensions of the corresponding uv grayscale image
    uv_imageDims = size(uv_image);
    
    %resize the inner mask to match the size of the corresponding uv grayscale
    innerMask = imresize(innerMask, [uv_imageDims(1), uv_imageDims(2)]);
    
    %convert the inverted mask to uint16 so it can be multiplied by its
    %corresponding grayscale image later
    innerMask = uint16(innerMask);
    
    %write the inverted mask to file
    targetFilePath = [targetDir, targetName, num2str(sliceIndex, '%04d'), '.tif'];
    imwrite(innerMask, targetFilePath);

    sliceIndex = sliceIndex + 1;
end