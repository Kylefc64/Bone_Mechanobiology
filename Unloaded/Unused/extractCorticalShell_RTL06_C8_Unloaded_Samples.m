function extractCorticalShell_RTL06_C8_Unloaded_Samples()

%%%%%%%%%%% Enter inputs below %%%%%%%%%%

%spec_num = {'55', '66', '69'};
spec_num = {'69'};
num_specs = length(spec_num);

for i = 1:num_specs
    innerMaskDir = ['\\Biomech-10\j\RTL06_R', spec_num{i}, '_C8_Processed\Tiled\Masks\']; %consistently named
    innerMaskName = ['RTL06_R', spec_num{i}, '_C8_masks_'];
    
    outerMaskDir = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_num{i}, '_C8_Processed\CT_binary_registered\']; %consistently named
    outerMaskName = 'CT_Binary_Registered_';
    
    imageDir = ['\\Biomech-10\j\RTL06_R', spec_num{i}, '_C8_Processed\Tiled\Gray\OP\']; %consistently named
    imageName = ['RTL06_R', spec_num{i}, '_C8_gray'];
    
    %(Moved results to \\Biomech-10\i\RTL06_Cortical_Processed\)
    targetDir = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_num{i},'_C8_Processed\UV_Cortical_Shells\'];
    targetName = ['RTL06_R', spec_num{i}, '_C8_UV_Cortical_Shell_'];
    
    beginIndex = {0,0,0};
    endIndex = {1032, 1198, 1053};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sliceIndex = beginIndex{i};
    
    while(sliceIndex <= endIndex{i})
        %Set up the image paths and read in the images
        innerMaskFilePath = [innerMaskDir, innerMaskName, num2str(sliceIndex, '%04d'), '.tif'];
        innerMask = imread(innerMaskFilePath);
        
        outerMaskFilePath = [outerMaskDir, outerMaskName, num2str(sliceIndex, '%04d'), '.tif'];
        outerMask = imread(outerMaskFilePath);
        
        imageFilePath = [imageDir, 'UV_', num2str(sliceIndex + 1, '%04d_'), imageName, '.tif'];
        image = imread(imageFilePath);
        
        %Get the dimensions of the grayscale image
        imageDims = size(image);
        
        %resize the masks to match the dimensions of the grayscale image
        innerMask = imresize(innerMask, [imageDims(1), imageDims(2)]);
        outerMask = imresize(outerMask, [imageDims(1), imageDims(2)]);
        
        %Invert the inner mask
        innerMask = ~innerMask;
        
        %Find the size of the largest connected component in the outer mask
        CC = bwconncomp(outerMask);
        numPix = cellfun(@numel, CC.PixelIdxList);
        [biggest, idx] = max(numPix);
        
        %Discard connected components smaller than 1% the size of the largest component
        outerMask = bwareaopen(outerMask, floor(0.01 * biggest));
        
        %Convert masks to uint16 data type
        innerMask = uint16(innerMask);
        outerMask = uint16(outerMask);
        
        %Apply the inner and outer masks to the grayscale image to produce the
        %final image of the cortical shell
        image = image .* innerMask .* outerMask;
        
        %Write the final image to file
        targetFilePath = [targetDir, targetName, num2str(sliceIndex, '%04d'), '.tif'];
        imwrite(image, targetFilePath);
        
        sliceIndex = sliceIndex + 1;
    end
end