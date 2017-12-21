function BoneStats_Script_Cortical_Unloaded(specimen_number)

%specimen_number = { '55', '66', '69'};
%specimen_number = { '55'}; %run 66 and 69 after Erin takes a look at CA thresholding

%1 corresponds with the endosteal surface
%2 corresponds with the periosteal surface

voxel_width = 2.75; %voxel width in microns
voxel_height = 2.75; %voxel height in microns
voxel_depth = 5.00; %voxel depth in microns
area_scale = 1000000; %for conversion from microns^2 to (mm)^2
vol_scale = 1000000000; %for conversion from microns^3 to (mm)^3

L = length(specimen_number);
num_regs = 3; %number of ROIs
num_cols = 12; %number of columns
BoneStats = cell(2*(num_regs + 1) + 1, num_cols); %4 for 3 ROIs and 1 header row, +1 for space in between endo and periosteal data

headers = {'Specimen', 'ROI', 'MS((mm)^2)', 'BS((mm)^2)', 'MS/BS', 'BV((mm)^3)', ...
    'BFV((mm)^3)', 'Ct.Ar((mm)^2)', 'Tt.Ar((mm)^2)', 'Ct.Ar/Tt.Ar', 'Ct.Th(um)', 'MAR(um/day)'};
% MS = 'Mineralizing Surface' of this ROI((mm)^2)
% BS = 'Bone Surface' of this ROI((mm)^2)
% MS/BS = 'Mineralizing Surface / Bone Surface' for this ROI(unitless)
% BV = 'Bone Volume' of this ROI((mm)^3)
% BFV = 'Bone Formation Volume' of this ROI((mm)^3)
% Ct.Ar = Average 'Cortical Cross Sectional Area' for this ROI ((mm)^2)
% Tt.Ar = Average 'Total Cross Sectional Area' for this ROI ((mm)^2)
% Ct.Ar / Tt.Ar = Average 'Cortical Cross Sectional Area' per Total Cross Sectional Area' for this ROI (unitless)
% Ct.Th = Average 'Cortical Thickness' for this ROI (microns)
% MAR = Average 'Mineral Apposition Rate' for this ROI (microns per day)

for j = 1:num_cols
    BoneStats{1, j} = headers{j};
    BoneStats{num_regs + 3, j} = headers{j};
end


%inputDrive1 = '\\Biomech-11\n' ; %bfv images & inner masks
%inputDrive2 = '\\Biomech-10\i'; %UV Cortical Shells and Full Cortical Shell masks
saveDrive = '\\Biomech-10\i'; %output drive for MSBS_ROI#s

for i = 1:L
    spec_name = specimen_number{i};
    display(spec_name) %%%%
    specimen = ['RTL06_R' spec_name '_C8_Processed'];
    for j = 1:num_regs
    %for j = 3:num_regs
        %j = 1 for ROI1
        %j = 2 for ROI2
        %j = 3; %for ROI3
        %ROI3 is the region after ROI1 and before ROI2, not after ROI2
        roi = ['ROI', num2str(j)];
        
        tic
        
        message = ['Loading binary images for specimen R', spec_name, ' ', roi, ' ...\n'];
        fprintf(message);
        
        %Call this function if any changes are made to how the binary images are loaded and pre-processed:
        %[bw_BFV_img, bw_UV_img, inner_mask_img, bw_UV_holes, CS_filled, surface_masks, start_slice, end_slice] = Make_MillData_Highres_Cortical(spec_name, inputDrive1, inputDrive2, saveDrive, roi);
        %Otherwise, just load the already processed data from the saved Matlab form:
        path = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_name, '_C8_Processed\Tiled\MillDataBinary_', roi, '.mat'];
        load(path);
        
        %Find starting and ending indices of current ROI
        [start_slice, end_slice] = RTL06_RegionOfInterest_Cortical(spec_name, roi);
        
        savDir = [saveDrive '\RTL06_Cortical_Processed\' specimen '\Tiled\']; %output directory
        if isdir(savDir)==0; mkdir(savDir); end
        
        %Process the binary images to retrieve useful data
        message = ['Processing binary images of specimen R', spec_name, ' ', roi, ' to retrieve data ...\n'];
        fprintf(message);
        tic
        %MSBS_matrix_input_Cortical(...) returns 5 2x1 matrices
        [mineralizing_surface, bone_surface, formation_volume, Ct_Th, MAR] = MSBS_matrix_input_Cortical(bw_UV_img, bw_BFV_img, inner_mask_img, bw_UV_holes, surface_masks, savDir, start_slice, end_slice, spec_name, roi);
        toc
        
        BoneStats{j+1,1} = ['R', spec_name, ' Endosteal'];
        BoneStats{j+6,1} = ['R', spec_name, ' Periosteal'];
        BoneStats{j+1,2} = num2str(j); %Region of Interest
        BoneStats{j+6,2} = num2str(j); %Region of Interest
        BoneStats{j+1,3} = (mineralizing_surface(1) * (voxel_height*voxel_depth)) / area_scale; %Mineralizing Surface
        BoneStats{j+6,3} = (mineralizing_surface(2) * (voxel_height*voxel_depth)) / area_scale; %Mineralizing Surface
        BoneStats{j+1,4} = (bone_surface(1) * (voxel_height*voxel_depth)) / area_scale; %Bone Surface
        BoneStats{j+6,4} = (bone_surface(2) * (voxel_height*voxel_depth)) / area_scale; %Bone Surface
        BoneStats{j+1,5} = mineralizing_surface(1)./bone_surface(1);
        BoneStats{j+6,5} = mineralizing_surface(2)./bone_surface(2);
        
        BV = sum(sum(sum(bw_UV_holes)));
        BoneStats{j+1,6} = (BV * (voxel_width*voxel_height*voxel_depth)) / vol_scale; %bone Volume
        BoneStats{j+6,6} = (BV * (voxel_width*voxel_height*voxel_depth)) / vol_scale; %bone Volume
        
        FV = formation_volume(1);
        BoneStats{j+1,7} = (FV * (voxel_width*voxel_height*voxel_depth)) / vol_scale; %Bone Formation Volume
        FV = formation_volume(2);
        BoneStats{j+6,7} = (FV * (voxel_width*voxel_height*voxel_depth)) / vol_scale; %Bone Formation Volume
        
        Ct_Ar = sum(sum(sum(bw_UV_holes))) / (end_slice - start_slice + 1); %Average Cortical Cross Sectional Area
        BoneStats{j + 1, 8} = (Ct_Ar * (voxel_height*voxel_width)) / area_scale; %Average Cortical Thickness
        BoneStats{j + 6, 8} = (Ct_Ar * (voxel_height*voxel_width)) / area_scale; %Average Cortical Thickness
        Tt_Ar = sum(sum(sum(CS_filled))) / (end_slice - start_slice + 1); %Average total cross sectional area
        BoneStats{j + 1, 9} = (Tt_Ar * (voxel_height*voxel_width)) / area_scale; %Average total vertebral cross sectional area
        BoneStats{j + 6, 9} = (Tt_Ar * (voxel_height*voxel_width)) / area_scale; %Average total vertebral cross sectional area
        BoneStats{j + 1, 10} = Ct_Ar / Tt_Ar; %Average cortical area divided by total vertebral cross sectional area
        BoneStats{j + 6, 10} = Ct_Ar / Tt_Ar; %Average cortical area divided by total vertebral cross sectional area
        BoneStats{j+1,11} = Ct_Th * voxel_width; %Average Cortical Thickness
        BoneStats{j+6,11} = Ct_Th * voxel_width; %Average Cortical Thickness
        BoneStats{j+1,12} = MAR(1) * voxel_width; %Average MAR (mineral apposition rate)
        BoneStats{j+6,12} = MAR(2) * voxel_width; %Average MAR (mineral apposition rate)
        
        clear bw_BFV_img  bw_BFV_img inner_mask_img mineralizing_surface bone_surface formation_volume %%%%
        toc
    end
    
    filename = [saveDrive, '\RTL06_Cortical_Processed\RTL06_R' spec_name, '_C8_Processed\Tiled\R', spec_name, '_C8_BoneStats.xls'];
    xlswrite(filename, BoneStats(:,:));
end

