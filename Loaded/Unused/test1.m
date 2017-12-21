function [endo_BF_SED_Stats, perio_BF_SED_Stats] = test1()
%function [endo_BF_SED_Stats, perio_BF_SED_Stats] = test1(start_slice, end_slice, spec_name, ROI)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spec_name = '53'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roi = 'ROI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[start_slice, end_slice] = RTL06_RegionOfInterest_Cortical(spec_name, roi);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_name, '_C8_Processed\Tiled\MillDataBinary_', roi, '.mat'];%%%%%%%%%%%%%%
load(path);%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maskededge = zeros(2, size(bw_UV_img, 1), size(bw_UV_img, 2), size(bw_UV_img, 3)) ;
maskededge = logical(maskededge) ;

message = ['Creating masked edges for R', spec_name, ' ', roi, ' ...\n'];
fprintf(message);%%%%

for j = 1:size(bw_UV_img,3)
    
    if mod(j, 10) == 0
        message = ['Creating masked edge for slice ', num2str(j + start_slice - 1, '%04d'), ' ...\n'];
        fprintf(message);
    end
    
    edge_UV = edge(bw_UV_img(:,:,j), 'sobel');
    maskededge(2,:,:,j) = edge_UV .* squeeze(surface_masks(2,:,:,j)); %periosteal edge
    
    
    mask_slice = ~imdilate(inner_mask_img(:,:,j), strel('disk',2)) ;
    slice = edge_UV .* mask_slice;
    maskededge(1, :,:,j) = logical(slice) .* squeeze(surface_masks(1,:,:,j)); %endosteal edge
    clear slice
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SED_images = zeros(size(surface_masks));
%%%%%%%%%%%%%%%%%%%%%Read in SED_images
dir = '\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R53_C8_Processed\SED_Registered\';
start_idx = uint16(0);
end_idx = uint16(272);
name = ['R', spec_name, '_SED_Calibrated_transformed_0000.tif'];
slice = imread([dir, name]);
SED_images_Coarse = uint16(zeros(size(slice, 1), size(slice, 2), (end_idx - start_idx + 1)));
for i = 1:end_idx - start_idx + 1
    name = ['R', spec_name, '_SED_Calibrated_transformed_', num2str(i + start_idx - 1,'%04d'), '.tif'];
    slice = imread([dir, name]);
    SED_images_Coarse(:,:,i) = slice;
end

%Resize SED images here(?) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%Calculating BFV and SED correlation
dilated_edges = zeros(size(surface_masks));
for i = 1:2
    dilated_edges(i,:,:,:) = imdilate(squeeze(maskededge(i,:,:,:)), strel('disk', 5));
end

edge_SED = zeros(size(dilated_edges));
for i = 1:2
    edge_SED(i,:,:,:) = squeeze(dilated_edges(i,:,:,:)) .* squeeze(SED_images(i,:,:,:)); %%%%%%%%%%%%%%%%%%%%%%%%%%%
end

edge_BFV = zeros(size(dilated_edges));
for i = 1:2
    edge_BFV(i,:,:,:) = squeeze(dilated_edges(i,:,:,:)) .* bw_BFV_img(:,:,:);
end

%clear unneeded matrices here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

endo_BF_SED_Stats = [];
perio_BF_SED_Stats = [];

width = size(squeeze(edge_SED(1,:,:,1)), 1);
height = size(squeeze(edge_SED(1,:,:,1)), 2);

for n = 1:(end_slice - start_slice + 1)
    endo_SED_image = squeeze(edge_SED(1,:,:,n));
    perio_SED_image = squeeze(edge_SED(2,:,:,n));
    for j = 1:width
        for k = 1:height
            SED_val = endo_SED_image(j,k);
            if SED_val ~= 0
                inds = find(endo_BF_SED_Stats(:,1) == SED_val);
                
                %if SED_val is contained in BF_SED_Stats, increment '# pixels at this SED value'
                %if SED_val is not contained in BF_SED_Stats, add another row to BF_SED_Stats with values [SED_val, 1, 0];
                if size(inds, 1) == 0 %if SED_val is not found in BF_SED_Stats
                    endo_BF_SED_Stats(size(endo_BF_SED_Stats, 1) + 1, 1) = SED_val; %new SED_val
                    endo_BF_SED_Stats(size(endo_BF_SED_Stats, 1), 2) = 1; %# pixels at this SED_val
                else
                    endo_BF_SED_Stats(inds, 2) = endo_BF_SED_Stats(inds, 2) + 1; %increment # pixels at this SED_val
                end
                
                if bw_BFV_img(j,k) == 0 %if there is no bone formation at this pixel
                    endo_BF_SED_Stats(size(endo_BF_SED_Stats, 1), 3) = 0; %# pixels with no BF at this SED_val
                else
                    endo_BF_SED_Stats(size(endo_BF_SED_Stats, 1), 3) = 1; %# pixels with no BF at this SED_val
                end
            end
            
            SED_val = perio_SED_image(j,k);
            if SED_val ~= 0
                inds = find(perio_BF_SED_Stats(:,1) == SED_val);
                
                %if SED_val is contained in BF_SED_Stats, increment '# pixels at this SED value'
                %if SED_val is not contained in BF_SED_Stats, add another row to BF_SED_Stats with values [SED_val, 1, 0];
                if size(inds, 1) == 0 %if SED_val is not found in BF_SED_Stats
                    perio_BF_SED_Stats(size(perio_BF_SED_Stats, 1) + 1, 1) = SED_val; %new SED_val
                    perio_BF_SED_Stats(size(perio_BF_SED_Stats, 1), 2) = 1; %# pixels at this SED_val
                else
                    perio_BF_SED_Stats(inds, 2) = perio_BF_SED_Stats(inds, 2) + 1; %increment # pixels at this SED_val
                end
                
                if bw_BFV_img(j,k) == 0 %if there is no bone formation at this pixel
                    perio_BF_SED_Stats(size(perio_BF_SED_Stats, 1), 3) = 0; %# pixels with no BF at this SED_val
                else
                    perio_BF_SED_Stats(size(perio_BF_SED_Stats, 1), 3) = 1; %# pixels with no BF at this SED_val
                end
            end
        end
    end
end



%{

%A = [3,13,7;4,14,8;5,15,9;6,16,10;7,17,11;8,18,12]
%A = ['SED value', '# pixels at this SED value', '# pixels at this SED value with bone formation']

%for each pixel in each SED slice, find the SED_val:
SED_val = 10; %SED_val to search for
inds = find(A(:,1) == SED_val);

%if SED_val is contained in A, increment '# pixels at this SED value'
%if SED_val is not contained in A, add another row to A with values [SED_val, 1, 0];
if size(inds, 1) == 0 %if SED_val is not found in A
    A(size(A, 1) + 1, 1) = SED_val; %new SED_val
    A(size(A, 1), 2) = 1; %# pixels at this SED_val
    A(size(A, 1), 3) = 0; %# pixels with BF at this SED_val
else
    A(inds, 2) = A(inds, 2) + 1; %increment # pixels at this SED_val
end

A

%}



%proceed to determine how many pixels with this SED_value contain bone formation