function save_lowres_data(spec_names, num_highres_slices, num_lowres_slices)
%spec_names = {'53', '54', '57', '58', '62', '65', '70', '71'};
%spec_names = {'53', '54', '57', '58', '70', '71'}; %run 62 and 65 after Erin looks at CA thresholding
%num_highres_slices = [1199,1198,1088,1198,1199,1199,1198,1199];
%num_lowres_slices = [273,273,248,273,273,273,273,273];
num_specs = size(spec_names, 2);

for i = 1:num_specs
    spec_name = spec_names{i};
    
    for j = 1:3
        roi{j} = ['ROI', num2str(j)];
        [highres_start_slices{j}, highres_end_slices{j}] = RTL06_RegionOfInterest_Cortical(spec_name, roi{j});
    end
    
    lowres_start_slices = {0,0,0};
    lowres_end_slices = {0,0,0};
    lowres_start_slices{1} = round((num_lowres_slices(1)/num_highres_slices(1))*highres_start_slices{1});
    lowres_end_slices{2} = round((num_lowres_slices(2)/num_highres_slices(2))*highres_end_slices{2});
    
    for j = 1:3
        message = ['Loading bw_img_data for specimen R', spec_name, ', ', roi{j}, ' ...\n'];
        fprintf(message);
        bw_img_data_path = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_name, '_C8_Processed\Tiled\MillDataBinary_', roi{j}, '.mat'];
        load(bw_img_data_path);
        clear bw_img_data_path;
        clear CS_filled;
        clear  bw_UV_holes;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        maskededge = zeros(2, size(bw_UV_img, 1), size(bw_UV_img, 2), size(bw_UV_img, 3)) ;
        maskededge = logical(maskededge) ;
        
        message = ['Creating masked edges for R', spec_name, ' ', roi{j}, ' ...\n'];
        fprintf(message);
        
        for k = 1:size(bw_UV_img,3)
            
            if mod(k, 10) == 0
                message = ['Creating masked edge for slice ', num2str(k + highres_start_slices{j} - 1, '%04d'), ' ...\n'];
                fprintf(message);
            end
            
            edge_UV = edge(imerode(bw_UV_img(:,:,k), strel('disk', 4)), 'sobel'); %eroded periosteal edge
            maskededge(2,:,:,k) = edge_UV .* squeeze(surface_masks(2,:,:,k)); %periosteal edge
            
            
            mask_slice = ~imdilate(inner_mask_img(:,:,k), strel('disk',2)) ;
            slice = edge_UV .* mask_slice;
            maskededge(1, :,:,k) = logical(slice) .* squeeze(surface_masks(1,:,:,k)); %endosteal edge
            clear slice
        end
        clear mask_slice;
        clear bw_UV_img;
        clear inner_mask_img;
        clear surface_masks;
        
        %%%%%% Convert maskededge and BF to FE pixel size %%%%%
        FEvox = 22;
        CA_ip_vox = 2.75;
        CA_op_vox = 5;
        
        %convert CA pixels to FE pixels
        [CAindex ] = find(bw_BFV_img > 0);
        [l,m,n] = size(bw_BFV_img);
        clear bw_BFV_img;
        CAimagesize=[l,m,n];
        clear l m n
        [x,y,z] = ind2sub(CAimagesize, CAindex);
        
        x_FE = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
        y_FE = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
        z_FE = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );
        
        z_size = max(z_FE);
        
        if j == 1
            lowres_end_slices{j} = lowres_start_slices{j} + z_size - 1;
        elseif j == 2
            lowres_start_slices{j} = lowres_end_slices{j} - z_size + 1;
        elseif j == 3
            lowres_start_slices{j} = lowres_end_slices{1} + 1;
            lowres_end_slices{j} = lowres_start_slices{2} - 1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%Read in SED_images
        SED_dir = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_name, '_C8_Processed\SED_Registered\'];
        SED_name = ['R', spec_name, '_SED_Calibrated_transformed_0000.tif'];
        slice = imread([SED_dir, SED_name]);
        SED_images = uint16(zeros(size(slice, 1), size(slice, 2), (lowres_end_slices{j} - lowres_start_slices{j} + 1)));
        for m = 1:lowres_end_slices{j} - lowres_start_slices{j} + 1
            SED_name = ['R', spec_name, '_SED_Calibrated_transformed_', num2str(m + lowres_start_slices{j} - 1,'%04d'), '.tif'];
            slice = imread([SED_dir, SED_name]);
            SED_images(:,:,m) = slice;
        end
        clear slice;
        
        x_size = size(SED_images, 1);
        y_size = size(SED_images, 2);
        
        %Verify that subscripts are within range
        x_FE(find(x_FE == 0)) = 1;
        x_FE(find(x_FE > x_size)) = x_size;
        y_FE(find(y_FE == 0)) = 1;
        y_FE(find(y_FE > y_size)) = y_size;
        z_FE(find(z_FE == 0)) = 1;
        z_FE(find(z_FE > z_size)) = z_size;
        
        BFV_inds = sub2ind(size(SED_images), x_FE, y_FE, z_FE);
        BFV_inds = unique(BFV_inds);
        
        BFV = zeros(size(SED_images));
        BFV(BFV_inds) = 1;
        
        
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
        x_FE_endo(find(x_FE_endo == 0)) = 1;
        x_FE_endo(find(x_FE_endo > x_size)) = x_size;
        y_FE_endo(find(y_FE_endo == 0)) = 1;
        y_FE_endo(find(y_FE_endo > y_size)) = y_size;
        z_FE_endo(find(z_FE_endo == 0)) = 1;
        z_FE_endo(find(z_FE_endo > z_size)) = z_size;
        
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
        x_FE_perio(find(x_FE_perio == 0)) = 1;
        x_FE_perio(find(x_FE_perio > x_size)) = x_size;
        y_FE_perio(find(y_FE_perio == 0)) = 1;
        y_FE_perio(find(y_FE_perio > y_size)) = y_size;
        z_FE_perio(find(z_FE_perio == 0)) = 1;
        z_FE_perio(find(z_FE_perio > z_size)) = z_size;
        
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
        
        %save histogram data
        savDir = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R',spec_name,'_C8_Processed\SED_Data\'] ;
        save([savDir,'HistData_R', spec_name, '_', roi{j},'.mat'], 'BFV_inds', 'endo_inds', 'perio_inds', 'BFV', 'endo_edge', 'perio_edge', 'endo_edge_SED', 'perio_edge_SED', 'endo_edge_BFV', 'perio_edge_BFV');
    end
end

%{
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

%}