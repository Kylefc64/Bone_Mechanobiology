function [endo_BF_SED_Stats, perio_BF_SED_Stats] = test2()
%function [endo_BF_SED_Stats, perio_BF_SED_Stats] = test1(start_slice, end_slice, spec_name, ROI)
num_highres_slices = [1200,1199,1200,1198]; %... etc... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_SED_slices = [273,273,272,273]; %... etc... %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spec_name = '53'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roi = 'ROI1'; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[start_slice, end_slice] = RTL06_RegionOfInterest_Cortical(spec_name, roi);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_name, '_C8_Processed\Tiled\MillDataBinary_', roi, '.mat'];%%%%%%%%%%%%%%
load(path);%%%%%%%%%%%%%%%%%%%%%
clear CS_filled;
clear  bw_UV_holes;

%incorporate for loop somehow
%SED_start_slice = round((start_slice / num_highres_slices(i)) * num_SED_slices(i));%%%%%%%%%%%%%%%%%%%%%%%%%%
%SED_end_slice = round((end_slice / num_highres_slices(i)) * num_SED_slices(i));%%%%%%%%%%%%%%%%%%%%%%%

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
clear mask_slice;
clear bw_UV_img;
clear inner_mask_img;
clear surface_masks;

%%%%%%%%%%%%%%%%%%%%%Read in SED_images
dir = '\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R53_C8_Processed\SED_Registered\';
%start_idx = round((start_slice / num_highres_slices(i)) * num_SED_slices(i));%%%%%%%%%%%%%%%%%%%%%%%%%%
%end_idx = round((end_slice / num_highres_slices(i)) * num_SED_slices(i)) - 1;%%%%%%%%%%%%%%%%%%%%%%%
start_idx = uint16(57);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end_idx = uint16(115);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
name = ['R', spec_name, '_SED_Calibrated_transformed_0000.tif'];
slice = imread([dir, name]);
SED_images = uint16(zeros(size(slice, 1), size(slice, 2), (end_idx - start_idx + 1)));
for i = 1:end_idx - start_idx + 1
    name = ['R', spec_name, '_SED_Calibrated_transformed_', num2str(i + start_idx - 1,'%04d'), '.tif'];
    slice = imread([dir, name]);
    SED_images(:,:,i) = slice;
end
clear slice;


%%%%%%%%%%%%%%%%%%%%%Calculating BFV and SED correlation

%{
dilated_edges = zeros(size(surface_masks));
clear surface_masks; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%}

%clear unneeded matrices here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Convert maskededge and BF to FE pixel size %%%%%
FEvox = 22;
CA_ip_vox = 2.75;
CA_op_vox = 5;

%convert CA pixels to FE pixels
[CAindex ] = find(bw_BFV_img > 0);
[l,m,n] = size(bw_BFV_img);
clear bw_BFV_img; %%%%%%%%%%%%
CAimagesize=[l,m,n];
clear l m n
[x,y,z] = ind2sub(CAimagesize, CAindex);

x_FE = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
y_FE = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
z_FE = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );

%Verify that subscripts are within range
z_FE(find(z_FE == 0)) = 1;
z_FE(find(z_FE > size(SED_images, 3))) = size(SED_images, 3);

BFV_inds = sub2ind(size(SED_images), x_FE, y_FE, z_FE);
BFV_inds = unique(BFV_inds);

BFV = zeros(size(SED_images));
BFV(BFV_inds) = 1;

%{
%convert CA pixels to FE pixels
[endo_CAindex ] = find(squeeze(edge_BFV(1,:,:,:)) > 0);
[l,m,n]=size(squeeze(edge_BFV(1,:,:,:)));
endo_CAimagesize=[l,m,n];
clear l m n
[x,y,z] = ind2sub(endo_CAimagesize, endo_CAindex);

x_FE_endo = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
y_FE_endo = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
z_FE_endo = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );

%Verify that subscripts are within range
z_FE_endo(find(z_FE_endo == 0)) = 1;
z_FE_endo(find(z_FE_endo > size(SED_images, 3))) = size(SED_images, 3);

endo_inds = sub2ind(size(SED_images), x_FE_endo, y_FE_endo, z_FE_endo);
endo_inds = unique(endo_inds);

endo_BF = zeros(size(SED_images));
endo_BF(endo_inds) = 1;


[perio_CAindex ] = find(squeeze(edge_BFV(2,:,:,:)) > 0);
[l,m,n]=size(squeeze(edge_BFV(2,:,:,:)));
perio_CAimagesize=[l,m,n];
clear l m n
[x,y,z] = ind2sub(perio_CAimagesize, perio_CAindex);

x_FE_perio = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
y_FE_perio = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
z_FE_perio = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );

%Verify that subscripts are within range
z_FE_perio(find(z_FE_perio == 0)) = 1;
z_FE_perio(find(z_FE_perio > size(SED_images, 3))) = size(SED_images, 3);

perio_inds = sub2ind(size(SED_images), x_FE_perio, y_FE_perio, z_FE_perio);
perio_inds = unique(perio_inds);

perio_BF = zeros(size(SED_images));
perio_BF(endo_inds) = 1;
%}


%%%%% convert maskededge pixels to FE pixels %%%%%
[endo_edgeindex ] = find(squeeze(maskededge(1,:,:,:)) > 0);
[l,m,n]=size(squeeze(maskededge(1,:,:,:)));
endo_edgeimagesize=[l,m,n];
clear l m n
[x,y,z] = ind2sub(endo_edgeimagesize, endo_edgeindex);

x_FE_endo = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
y_FE_endo = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
z_FE_endo = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );

%Verify that subscripts are within range
z_FE_endo(find(z_FE_endo == 0)) = 1;
z_FE_endo(find(z_FE_endo > size(SED_images, 3))) = size(SED_images, 3);

endo_inds = sub2ind(size(SED_images), x_FE_endo, y_FE_endo, z_FE_endo);
endo_inds = unique(endo_inds);

endo_edge = zeros(size(SED_images));
endo_edge(endo_inds) = 1;



[perio_edgeindex ] = find(squeeze(maskededge(2,:,:,:)) > 0);
[l,m,n]=size(squeeze(maskededge(2,:,:,:)));
perio_edgeimagesize=[l,m,n];
clear l m n
[x,y,z] = ind2sub(perio_edgeimagesize, perio_edgeindex);

x_FE_perio = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
y_FE_perio = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
z_FE_perio = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );

%Verify that subscripts are within range
z_FE_perio(find(z_FE_perio == 0)) = 1;
z_FE_perio(find(z_FE_perio > size(SED_images, 3))) = size(SED_images, 3);

perio_inds = sub2ind(size(SED_images), x_FE_perio, y_FE_perio, z_FE_perio);
perio_inds = unique(perio_inds);

perio_edge = zeros(size(SED_images));
perio_edge(perio_inds) = 1;


%%% (convert to maskededge_coarse stack here) %%%


%multiply SED_images stack by maskededges to separate strains at
%endosteal and periosteal surfaces
endo_edge_SED = zeros(size(endo_edge));
perio_edge_SED = zeros(size(perio_edge));

endo_edge_SED(:,:,:) = endo_edge(:,:,:) .* double(SED_images(:,:,:));
perio_edge_SED(:,:,:) = perio_edge(:,:,:) .* double(SED_images(:,:,:));


%multiply bone formation by maskededge to separate BF at endosteal and periosteal surfaces
endo_edge_BFV = zeros(size(BFV));
perio_edge_BFV = zeros(size(BFV));
endo_edge_BFV(:,:,:) = endo_edge(:,:,:) .* double(BFV(:,:,:));
perio_edge_BFV(:,:,:) = perio_edge(:,:,:) .* double(BFV(:,:,:));



%%%%% Plot SED histograms %%%%%
hist(perio_edge_SED(perio_inds), 50);
hold on
hist(endo_edge_SED(endo_inds), 50);


OD_Peri = log(nonzeros(perio_edge_SED(perio_inds))); 
OD_End = log(nonzeros(endo_edge_SED(endo_inds))); 
[n1,x1] = hist(OD_Peri); [n2,x2] = hist(OD_End); 
n=[n1' n2'];
figure; bar(x1,n,1.5)
legend('Periosteal Surface', 'Endosteal Surface', 'Location', 'NorthEast')
xlabel('Strain Value')
ylabel('Count')
title(['Specimen R53, strain range -6000 to -3000 ue'])


%%%%% Plot BFV histograms %%%%%
hist(perio_edge_BFV(perio_inds), 50);
hold on
hist(endo_edge_BFV(endo_inds), 50);


OD_Peri = log(nonzeros(perio_edge_BFV(perio_inds))); 
OD_End = log(nonzeros(endo_edge_BFV(endo_inds))); 
[n1,x1] = hist(OD_Peri); [n2,x2] = hist(OD_End); 
n=[n1' n2'];
figure; bar(x1,n,1.5)
legend('Periosteal Surface', 'Endosteal Surface', 'Location', 'NorthEast')
xlabel('Strain Value')
ylabel('Count')
title(['Specimen R53, strain range -6000 to -3000 ue'])



%{
for i = 1:2
    edge_SED(i,:,:,:) = squeeze(maskededge_coarse(i,:,:,:)) .* squeeze(SED_images(i,:,:,:)); %%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
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
%}


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

