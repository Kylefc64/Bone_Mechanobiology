function endo_and_periosteal_separation1()

%%%%%%%%%%% Enter inputs below %%%%%%%%%%

%innerMaskDir = '\\Biomech-11\n\RTL06_R54_C8_Processed\Tiled\Masks\';
%innerMaskName = 'RTL06_R54_C8_masks_';


%outerMaskDir = '\\Biomech-11\n\RTL06_R54_C8_Processed\Tiled\CT_binary_registered\';
%outerMaskName = 'R54_C8_Binary_Mask';

%imageDir = '\\Biomech-11\n\RTL06_R54_C8_Processed\Tiled\Gray\OP\';
%imageName = 'RTL06_R54_C8_gray';

%targetDir = '\\Biomech-11\n\RTL06_R54_C8_Processed\Tiled\UV_Cortical_Shells\';
%targetName = 'RTL06_R54_C8_UV_Cortical_Shell_';

UVShellDir = '\\Biomech-11\n\RTL06_R53_C8_Processed\Tiled\UV_Cortical_Shells\';
UVShellName = 'RTL06_R53_C8_UV_Cortical_Shell_';

beginIndex = 600;
endIndex = 600;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sliceIndex = beginIndex;

while(sliceIndex <= endIndex)
    %Set up the image paths and read in the images
    UVShellFilePath = [UVShellDir, UVShellName, num2str(sliceIndex, '%04d'), '.tif'];
    UVShell = imread(UVShellFilePath);
    
    mask = UVShell > 0;
    
    dims = size(mask);
    
    coord_matrix = zeros(dims(1), dims(2), 2);
    
    for i = 1:dims(1)
        for j = 1:dims(2)
            if mask(i, j) > 0
                coord_matrix(i, j, 1:2) = (i:j);
            end
        end
    end
    
    
    %outerMaskFilePath = [outerMaskDir, outerMaskName, num2str(sliceIndex, '%04d'), '.tif'];
    %outerMask = imread(outerMaskFilePath);
    
    %imageFilePath = [imageDir, 'UV_', num2str(sliceIndex + 1, '%04d_'), imageName, '.tif'];
    %image = imread(imageFilePath);
    
    %Get the dimensions of the grayscale image
    %imageDims = size(image);
    
    %resize the masks to match the dimensions of the grayscale image
    %innerMask = imresize(innerMask, [imageDims(1), imageDims(2)]);
    %outerMask = imresize(outerMask, [imageDims(1), imageDims(2)]);
    
    %Invert the inner mask
    %innerMask = ~innerMask;
    
    %Find the size of the largest connected component in the outer mask
    %CC = bwconncomp(outerMask);
    %numPix = cellfun(@numel, CC.PixelIdxList);
    %[biggest, idx] = max(numPix);
    
    %Discard connected components smaller than 1% the size of the largest component
   	%outerMask = bwareaopen(outerMask, floor(0.01 * biggest));
    
    %Convert masks to uint16 data type
    %innerMask = uint16(innerMask);
    %outerMask = uint16(outerMask);
    
    %Apply the inner and outer masks to the grayscale image to produce the
    %final image of the cortical shell
    %image = image .* innerMask .* outerMask;

    %Write the final image to file
    %targetFilePath = [targetDir, targetName, num2str(sliceIndex, '%04d'), '.tif'];
    %imwrite(image, targetFilePath);
    
    sliceIndex = sliceIndex + 1;
end