function [bw_BFV_img, bw_UV_img, inner_mask_img, bw_UV_holes, CS_filled, surface_masks, start_slice, end_slice] = Make_MillData_Highres_Cortical(spec_name, inputDrive1, inputDrive2, inputDrive3, saveDrive, ROI)
%function [bw_BFV_img, bw_UV_img, inner_mask_img, outer_mask_img] = Make_MillData_Highres_Cortical(spec_name, inputDrive1, inputDrive2, saveDrive, ROI)

%% inport bone formation volume images
%Full binary images of an entire cross section of vertebra that shows
%bone formation across the entire cross section

[start_slice, end_slice] = RTL06_RegionOfInterest_Cortical(spec_name, ROI) ;
%Gets starting and ending slices based on specimen number and ROI (#1 or #2)
%Middle region was left out for cancellous bone because of hourglass shape
%of cancellous bone location
%Added third middle region for cortical bone

message = ['Processing R', spec_name, ' ', ROI, ' ...\n'];
fprintf(message);


codeDir = '\\Biomech-10\i\MatlabCode\Cortical\Unloaded\';
bfvDir1 = [inputDrive3 , '\RTL06_Cortical_Processed', '\RTL06_R',spec_name,... %change me!!! erin - yup 
    '_C8_Processed\CA_cortical_thresh\']; %change me!!! erin - i did i swear


cd(bfvDir1);
bfvFil1 = dir('*CAsignal*.tif'); %change me!!!? erin - yup 
%CA = 'Calcein'
%OXY = 'Oxytetracycline'

cd(codeDir) ;

slice = imread([bfvDir1 bfvFil1(1).name]);
bw_BFV_img = zeros(size(slice,1), size(slice,2), end_slice - start_slice + 1);
%creates a matrix capable of storing every image in the ROI
%end_slice - start_slice + 1 = 260 for distal and proximal ROIs;

fprintf('Loading Calcein images ...\n');

count = 1;
for m = start_slice:end_slice
    bfv_slice = imread([bfvDir1 bfvFil1(m).name]);
    bw_BFV_img(:,:,count) = bfv_slice ;
    clear bfv_slice
    count = count+1;
end

bw_BFV_img = logical(bw_BFV_img) ;



%% inport mask images
%Original inner traced cancellous masks
%Inner masks will be dilated to remove edges that are not true edges (those that
%are caused by masking the cancellous tissue - edges that are actually the
%interior of trabeculae)

inner_maskDir1 = [inputDrive1,'\RTL06_R',spec_name,...
    '_C8_Processed\Tiled\Masks\'];


%inport bone formation volume
% BFV images
cd(inner_maskDir1);
inner_maskFil1 = dir('*mask*.tif');

cd(codeDir) ;
inner_mask_img = zeros(size(bw_BFV_img) );

fprintf('Loading inner masks ...\n');%%%%

count = 1;
for m = start_slice:end_slice
    inner_mask_slice = imread([inner_maskDir1 inner_maskFil1(m).name]);
    inner_mask_img(:,:,count) = inner_mask_slice ;
    clear inner_mask_slice
    count = count+1;
end

inner_mask_img = logical(inner_mask_img) ;


%% inport bone uv images
%Thresholded images of the UV Cortical Shells that yield a truer edge than
%the CT masks due to the buffer between true UV edge and CT edge

%Import thresholded uv images and registered CT masked uv images
%and multiply them to create better endosteal and periosteal edges

uvDir1 = [inputDrive2,'\RTL06_Cortical_Processed\RTL06_R',spec_name,...
    '_C8_Processed\UV_Cortical_Shells\'];

thresh_dir = [inputDrive1,'\RTL06_R',spec_name,...
    '_C8_Processed\Tiled\Thresh_Resampled\'];

%inport bone formation volume
% BFV images
cd(uvDir1);
uvFil1 = dir('*UV*.tif');
cd(codeDir) ;
bw_UV_img = zeros(size(bw_BFV_img) );

cd(thresh_dir);
threshFil1 = dir('*thresh.tif');
cd(codeDir) ;

%bw_UV_holes is a mask of the cortical shell before small holes (nutrient
%foramens, etc. are removed)
bw_UV_holes = zeros(size(bw_BFV_img) ); %unfilled bw_uv_img (to be used to find bone volume)%%%%

%CS_filled will later be used to calculate the total cross sectional
%area of the vertebrae
CS_filled = zeros(size(bw_BFV_img)); %cross section filled

%Surface masks: 1 corresponds with endosteal surface, 2 with periosteal surface
%Surface masks are used to define the spaces that contain endosteal vs periosteal edges
%surface_masks(1,:,:,i) is used to define the space that contains endosteal edges, while
%surface_masks(2,:,:,i) is used to define the space containing periosteal edges
surface_masks = zeros(2, size(bw_UV_img, 1), size(bw_UV_img, 2), size(bw_UV_img, 3));

fprintf('Loading UV and thresholded images and storing as cleaned masks ...\n');%%%%
fprintf('... AND creating endosteal and periosteal surface masks ...\n');

for m = start_slice:end_slice
    if mod(m, 10) == 0
        message = ['Processing UV image ', num2str(m, '%04d'), ' ... \n'];
        fprintf(message);
    end
    
    %Coarsen images
    uv_slice = imread([uvDir1 uvFil1(m).name]);
    uv_slice = imresize(uv_slice, [size(bw_UV_img, 1), size(bw_UV_img, 2)]);
    
    thresh_slice = imread([thresh_dir threshFil1(m).name]);
    %thresh_slice = imresize(thresh_slice, [size(bw_UV_img, 1), size(bw_UV_img, 2)]);
    
    %Turn the uv image into binary
    mask1 = uv_slice > 0;
    clear uv_slice;
    
    %mask2 will help smoothen the periosteal edge of the cortical shell mask
    %and erode it to help get rid of buffer left at the periosteal edge by registered CT mask
    
    %Apply the thresholded masks to remove most of the periosteal buffer
    %(using only filled images to leave the endosteal edge as is)
    mask2 = imfill(mask1, 'holes') .* imfill(thresh_slice, 'holes');
    %Smoothen the periosteal surface
    mask2 = imerode(mask2, strel('disk', 10));
    mask2 = imdilate(mask2, strel('disk', 10));
    
    %Erode the periosteal surface to bring in edges
    %{
    max_rad = 0;
    max_edge = edge(mask2, 'sobel');
    for r = 1:10
        temp = imerode(mask2, strel('disk', r));
        temp_edge = edge(temp, 'sobel');
        if sum(sum(max_edge .* bw_BFV_img(:,:,m))) < sum(sum(temp_edge .* bw_BFV_img(:,:,m)))
            max_rad = r;
            max_edge = temp_edge;
        end
    end
    mask2 = imerode(mask2, strel('disk', max_rad));
    %}
    %mask2 = imerode(mask2, strel('disk', 5));
    
    CS_filled(:,:,m - start_slice + 1) = mask2;
    
    bw_UV_holes(:,:,m - start_slice + 1) = mask2 .* mask1;
    
    %Invert mask1
    %Find connected components (holes)
    %Keep only the two largest connected components (background + endosteal hole)
    %Invert mask of two largest connected components (holes)
    %Apply inverted two largest CC to mask2 and save as bw_UV_img(:,:,count)
    
    mask1 = ~mask1;
    
    %Find the size of the largest connected component in the outer mask
    CC = bwconncomp(mask1);
    numPix = cellfun(@numel, CC.PixelIdxList);
    [biggest, idx] = max(numPix);
    
    %%%%%
    %Discard connected components (holes) smaller than 1% the size of the largest hole
    mask1 = bwareaopen(mask1, floor(0.01 * biggest));
    full_mask = ~mask1 .* mask2;
    bw_UV_img(:,:,m - start_slice + 1) = full_mask;
    
    %Create endosteal surface masks%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Create a "frame" of width 1 pixel around the entire image to determine
    %whether or not a CC is touching the boundary
    %Remove all CCs touching the boundary UNLESS it is the only remaining CC;
    %the remaining region will mask the endosteal hole
    
    %An image of the same size of mask1 with 1 pixels at the border
    frame = zeros(size(full_mask));
    frame(1,:) = 1; %fill in top row
    frame(:,1) = 1; %fill in left column
    frame(size(frame, 1),:) = 1; %fill in bottom row
    frame(:, size(frame, 2)) = 1; %fill in right column
    
    mask3 = ~full_mask; %mask3 = holes
    
    CC = bwconncomp(mask3);
    %Find the center point of the cortical slice
    [x_coord, y_coord] = Find_Center(full_mask);
    center = zeros(size(frame));
    center(x_coord, y_coord) = 1;
    center = imdilate(center, strel('disk', 10));
    for i = 1:CC.NumObjects
        %Create an image for each region
        mask = zeros(size(mask3));
        mask(CC.PixelIdxList{i}) = 1;
        %If a region does not contain the center point, remove it from the mask
        if max(max(mask .* center)) == 0 %meaning the current CC does not contain the center point
            mask3 = mask3 - mask;
        end
    end
    
    %If there is no hole in the cortical shell, use this region (dilated) as the endosteal surface mask
    if max(max(mask3 .* frame)) == 0 %(not touching frame)
        %populate endosteal masks
        surface_masks(1,:,:,m - start_slice + 1) = imdilate(mask3, strel('disk', 20));
        
        %populate periosteal masks
        surface_masks(2, :,:,m - start_slice + 1) = imfill(full_mask, 'holes');
        surface_masks(2, :,:,m - start_slice + 1) = ~(imerode(squeeze(surface_masks(2,:,:,m - start_slice + 1)), strel('disk', 25)));
    else %if there is a hole in the cortical shell (nutrient foramen, etc.)
        %Use a method with a smaller possibility of there being a hole in the cortical shell
        CC = bwconncomp(mask1);
        %Find the center point of the cortical slice
        [x_coord, y_coord] = Find_Center(~mask1);
        center = zeros(size(frame));
        center(x_coord, y_coord) = 1;
        center = imdilate(center, strel('disk', 10));
        mask3 = ~mask1; %CT cortical mask before being altered
        for i = 1:CC.NumObjects
            %Create an image for each region
            mask = zeros(size(mask1));
            mask(CC.PixelIdxList{i}) = 1;
            %If a region does not contain the center point, remove it from the mask
            if max(max(mask .* center)) == 0 %meaning the current CC does not contain the center point
                mask1 = mask1 - mask;
            end
        end
        
        %If there is no hole in the cortical shell, use this region (dilated) as the endosteal surface mask
        if max(max(mask1 .* frame)) == 0 %(not touching frame)
            %populate endosteal masks
            surface_masks(1,:,:,m - start_slice + 1) = imdilate(mask1, strel('disk', 20));
            
            %populate periosteal masks
            surface_masks(2, :,:,m - start_slice + 1) = imfill(mask3, 'holes');
            surface_masks(2, :,:,m - start_slice + 1) = ~(imerode(squeeze(surface_masks(2,:,:,m - start_slice + 1)), strel('disk', 25)));
        else %if there is still a hole in the cortical shell (nutrient foramen, etc.), just dilate the traced inner masks
            %use a dilated inner mask to define the surfaces
            dilated = imdilate(inner_mask_img(:,:,m - start_slice + 1), strel('disk', 50));
            surface_masks(1,:,:,m - start_slice + 1) =  dilated; %endosteal surface
            
            surface_masks(2, :,:,m - start_slice + 1) = ~dilated; %periosteal surface
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

bw_UV_img = logical(bw_UV_img) ;
bw_UV_holes = logical(bw_UV_holes);
CS_filled = logical(CS_filled);
surface_masks = logical(surface_masks); %%%


%% save in matlab form
message = ['Saving specimen R' spec_name, ' ', ROI, ' in matlab form ...\n'];
fprintf(message);

savDir = [saveDrive,'\RTL06_Cortical_Processed\RTL06_R',spec_name,'_C8_Processed\Tiled\'] ;
save([savDir,'MillDataBinary_',ROI,'.mat'], 'bw_BFV_img', 'bw_UV_img', 'inner_mask_img', 'CS_filled', 'bw_UV_holes', 'surface_masks');
%save([savDir,'MillDataBinary_',ROI,'.mat'], 'bw_BFV_img', 'bw_UV_img', 'inner_mask_img', 'CS_filled', 'bw_UV_holes', 'surface_masks', '-v7.3');


end