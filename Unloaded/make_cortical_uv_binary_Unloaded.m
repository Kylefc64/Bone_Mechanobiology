function make_cortical_uv_binary_Unloaded(specimen_number)

%specimen_number = { '55', '66', '69'};
%specimen_number = { '55'}; %run 66 and 69 after Erin takes a look at CA thresholding

%1 corresponds with the endosteal surface
%2 corresponds with the periosteal surface

L = length(specimen_number);
num_regs = 3; %number of ROIs

inputDrive1 = '\\Biomech-10\j' ; %(bfv images) & inner masks
inputDrive2 = '\\Biomech-10\i'; %UV Cortical Shells and Full Cortical Shell masks
inputDrive3 = '\\Biomech-10\i'; %CA images %change me!!! erin - yup 
saveDrive = '\\Biomech-10\i'; %output drive for MSBS_ROI#s

for i = 1:L
    spec_name = specimen_number{i};
    display(spec_name) %%%%
    for j = 1:num_regs
    %for j = 3:num_regs
        %j = 1 for ROI1
        %j = 2 for ROI2
        %j = 3; %for ROI3
        %ROI3 is the region after ROI1 and before ROI2, not after ROI2
        
        tic
        
        roi = ['ROI', num2str(j)];
        Make_MillData_Highres_Cortical(spec_name, inputDrive1, inputDrive2, inputDrive3, saveDrive, roi);%%%%
        
        toc
        
    end
end