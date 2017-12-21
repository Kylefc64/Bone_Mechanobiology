function [mineralizing_surface,bone_surface,formation_volume, Ct_Th, MAR] = MSBS_matrix_input_Cortical(UV, BFV, innerMask, bw_UV_holes, surface_masks, savDir, start_slice, end_slice, spec_name, roi)

%Pre-allocate space for
mineralizing_surface = zeros(2, 1);
bone_surface = zeros(2, 1);
formation_volume = zeros(2, 1);

%UV is a binary mask of the cortical shell
%% smoothing UV surface
%se = strel('disk',5);

maskededge = zeros(2, size(UV, 1), size(UV, 2), size(UV, 3)) ;
maskededge = logical(maskededge) ;

%Find the average thickness of bone formation sites
%http://www.mathworks.com/help/images/ref/bwdist.html
%http://www.mathworks.com/help/images/ref/bwulterode.html
%http://homepages.inf.ed.ac.uk/rbf/HIPR2/distance.htm

message = ['Calculating MAR for specimen R', spec_name, ' ', roi, ' ...\n'];
fprintf(message);

sum_MAR = [0,0];
for i = 1:(end_slice - start_slice + 1)
    if mod(i, 10) == 0
        message = ['Calculating MAR for R', spec_name, ' ', roi, ' slice ', num2str(start_slice + i - 1, '%04d'), ' ...\n'];
        fprintf(message);
    end
    
    %Find endosteal BFV thickness for this slice%%%
    %Find the distance from every 0-valued pixel to the nearest non-zero pixel
    bw_dist = bwdist(~(BFV(:,:,i) .* squeeze(surface_masks(1,:,:,i)))); %%%%endosteal formation
    %Find the midline or midpoint of each BF region
    bw_ult_erode = bwulterode(bw_dist);
    %Find the thickness of each BF region
    result = 2 * (bw_dist .* bw_ult_erode);
    %Find the avg thickness
    BFV_Th = mean(mean(nonzeros(result)));
    %Sum the avg thickness of all slices
    if ~isnan(BFV_Th)
        sum_MAR(1) = sum_MAR(1) + BFV_Th;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Find periosteal BFV thickness for this slice%%%
    %Find the distance from every 0-valued pixel to the nearest non-zero pixel
    bw_dist = bwdist(~(BFV(:,:,i) .* squeeze(surface_masks(2,:,:,i)))); %%%%periosteal formation
    %Find the midline or midpoint of each BF region
    bw_ult_erode = bwulterode(bw_dist);
    %Find the thickness of each BF region
    result = 2 * (bw_dist .* bw_ult_erode);
    %Find the avg thickness
    BFV_Th = mean(mean(nonzeros(result)));
    %Sum the avg thickness of all slices
    if ~isnan(BFV_Th)
        sum_MAR(2) = sum_MAR(2) + BFV_Th;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%Divide by the time elapsed between fluorescent injections to find the MAR
time_elapsed = 5; %time elapsed in days
MAR(1) = (sum_MAR(1) / (end_slice - start_slice + 1)) / time_elapsed; %endosteal data
MAR(2) = (sum_MAR(2) / (end_slice - start_slice + 1)) / time_elapsed; %periosteal data


message = ['Creating masked edges and calculating Ct.Th for R', spec_name, ' ', roi, ' ...\n'];
fprintf(message);%%%%

Ct_Th_sum = 0;
for j = 1:size(UV,3)
    
    if mod(j, 10) == 0
        message = ['Creating masked edge and calculating Ct.Th for slice ', num2str(j + start_slice - 1, '%04d'), ' ...\n'];
        fprintf(message);
    end
    
    edge_UV = edge(UV(:,:,j), 'sobel');
    maskededge(2,:,:,j) = edge_UV .* squeeze(surface_masks(2,:,:,j)); %periosteal edge
    
    %Find the average cortical thickness for this slice%%%
    %Find the distance from every 0-valued pixel to the nearest non-zero pixel
    bw_dist = bwdist(~squeeze(UV(:,:,j)));
    %Find the midline or midpoint of each BF region
    bw_ult_erode = bwulterode(bw_dist);
    %Find the thickness of each BF region
    result = 2 * (bw_dist .* bw_ult_erode);
    %Find the avg thickness and add it to the sum of all avg thicknesses
    Ct_Th_sum = Ct_Th_sum + mean(mean(nonzeros(result)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    mask_slice = ~imdilate(innerMask(:,:,j), strel('disk',2)) ;
    slice = edge_UV .* mask_slice;
    maskededge(1, :,:,j) = logical(slice) .* squeeze(surface_masks(1,:,:,j)); %endosteal edge
    clear slice
end

clear Ct_Th;
Ct_Th = Ct_Th_sum / (end_slice - start_slice + 1);

message = ['Calculating bone_surface for R', spec_name, ' ', roi, ' ...\n'];
fprintf(message);

%Find the total Bone Surface for this ROI
for i = 1:2
    bone_surface(i) = 0;
    for j = 1:size(maskededge, 4)
        bone_surface(i) = bone_surface(i) + sum(sum(sum(squeeze(maskededge(i,:,:,j)))));
    end
end

%% BF

message = ['Calculating mineralizing_surface for R', spec_name, ' ', roi, ' ...\n'];
fprintf(message);

se = strel('disk', 5);
%BF signal contains the edges of old bone that are in contact with bone formation
BFsignal = zeros(size(maskededge));
for i = 1:2
    for j = 1:size(BFsignal, 4)
        BFsignal(i,:,:,j) = squeeze(maskededge(i,:,:,j)) .* logical(imdilate(BFV(:,:,j), se));
    end
end

for i = 1:2
    mineralizing_surface(i) = 0;
    for j = 1:size(BFsignal, 4)
        mineralizing_surface(i) = mineralizing_surface(i) + sum(sum(sum(squeeze(BFsignal(i,:,:,j)))));
    end
end

clear BF_grown;

se = strel(ones(5,5,5));
%both contains endosteal and periosteal edges combined with bone formation
both = zeros(size(maskededge));
for i = 1:size(BFV, 3)
    both(1,:,:,i) = squeeze(maskededge(1,:,:,i)) + squeeze(surface_masks(1,:,:,i)) .* imdilate(squeeze(BFsignal(1,:,:,i)), se);
    both(2,:,:,i) = squeeze(maskededge(2,:,:,i)) + squeeze(surface_masks(2,:,:,i)) .* imdilate(squeeze(BFsignal(2,:,:,i)), se);
end

message = ['Writing MSBS ', roi, ' images ...\n'];
fprintf(message);
for i = 1:size(both,4)
    slice = ['0000' num2str(i + start_slice - 1)];
    slice = slice(end-3:end);
    
    fullDir = [savDir 'MsBs_' roi '\Endosteal_Surface\'];
    if isdir(fullDir)==0; mkdir(fullDir); end
    imwrite(squeeze(both(1, :,:,i)), [fullDir 'MsBs_' slice '.tif'], 'compression', 'lzw')
    fullDir = [savDir 'MsBs_' roi '\Periosteal_Surface\'];
    if isdir(fullDir)==0; mkdir(fullDir); end
    imwrite(squeeze(both(2, :,:,i)), [fullDir 'MsBs_' slice '.tif'], 'compression', 'lzw')
end
clear both;

message = ['Writing BF_Only ', roi, ' images ...\n'];
fprintf(message);
for i = 1:size(BFsignal,4)
    slice = ['0000' num2str(i + start_slice - 1)];
    slice = slice(end-3:end);
    
    fullDir = [savDir 'Ms_Only_' roi '\Endosteal_Surface\'];
    if isdir(fullDir)==0; mkdir(fullDir); end
    imwrite(squeeze(BFsignal(1,:,:,i)), [fullDir 'Ms_Only_' slice '.tif'], 'compression', 'lzw')
    fullDir = [savDir 'Ms_Only_' roi '\Periosteal_Surface\'];
    if isdir(fullDir)==0; mkdir(fullDir); end
    imwrite(squeeze(BFsignal(2,:,:,i)), [fullDir 'Ms_Only_' slice '.tif'], 'compression', 'lzw')
end

clear BFsignal;
clear surface_masks;

%FV

message = ['Calculating formation_volume for R', spec_name, ' ', roi, ' ...\n'];
fprintf(message);%%%%%

se = strel(ones(4,4,2));
FV = zeros(size(maskededge));
for i = 1:2
    for j = 1:size(FV, 4)
        FV(i,:,:,j) = logical(imdilate(squeeze(maskededge(i,:,:,j)), se));
    end
end

for i = 1:2
    formation_volume(i) = 0;
    for j = 1:size(FV, 4)
        formation_volume(i) = formation_volume(i) + sum(sum(sum(squeeze(FV(i,:,:,j)) .* BFV(:,:,j))));
    end
end

end