%{
%%%%%%%%%%%%%%%%%%%%%%% Summary of Overall Process %%%%%%%%%%%%%%%%%%%%%%%
1. Register CT DICOMs with Thresh_Resampled TIFFs
 - See Lab Notebook Entry for 2016-06-20 for detailed method using Amira
2. Register FEM SED images with Registered CT masks
 - See Lab notebook Entry for 2016-07-07 for detailed method using Amira
3. Combine the CT masks with the traced cancellous masks to create UV
images of cortical shells
4. Use the resulting images as well as previously processed images to
calculate Bonestats and save binary masks of the endosteal and periosteal surfaces
5. Use these binary masks to associate SED with bone formation at the
endosteal and periosteal surfaces and to generate easily visualizeable data
in the form of histograms (and maybe other plots)
%}
function Cortical_Processing_Master()
%Verify that the image directories in the called functions are correct before running this script

%%%%%%%%%%%%%%%%%%%%%%% change the variables below %%%%%%%%%%%%%%%%%%%%%%%%
%(Note: For example, loaded_spec_nums{i} must correspond with num_highres_loaded_slices(i))
loaded_spec_nums = {'53', '54', '57', '58', '62', '65', '70', '71'}; %loaded specimen #s
unloaded_spec_nums = {'55', '56', '66', '69'}; %unloaded specimen #s
num_highres_loaded_slices = [1199,1198,1088,1198,1199,1199,1198,1199]; %number of CT mask slices per loaded specimen
num_lowres_loaded_slices = [273,273,248,273,273,273,273,273]; %number of FEM SED slices per loaded specimen
num_unloaded_slices = [1033,1199,1199,1054]; %number of CT mask slices per unloaded specimen
main_dir = '\\Biomech-10\i\MatlabCode\Cortical';
loaded_code_dir = '\\Biomech-10\i\MatlabCode\Cortical\Loaded';
unloaded_code_dir = '\\Biomech-10\i\MatlabCode\Cortical\Unloaded';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%3. Create a cortical UV shell using the registered CT masks
cd(loaded_code_dir);
Extract_Cortical_Shell_Loaded_Master(loaded_spec_nums, num_highres_loaded_slices);

cd(unloaded_code_dir);
Extract_Cortical_Shell_Unloaded_Master(unloaded_spec_nums, num_unloaded_slices);

%4. Calculate Bonestats
cd(loaded_code_dir);
make_cortical_uv_binary(loaded_spec_nums);
cd(loaded_code_dir);
BoneStats_Script_Cortical(loaded_spec_nums);

cd(unloaded_code_dir);
make_cortical_uv_binary_Unloaded(unloaded_spec_nums);
cd(unloaded_code_dir);
BoneStats_Script_Cortical_Unloaded(unloaded_spec_nums);

%5. Convert processed image data into readable histograms (only applicable to
%loaded specimens with FEM models)
cd(loaded_code_dir);
save_lowres_data(loaded_spec_nums, num_highres_loaded_slices, num_lowres_loaded_slices);

cd(loaded_code_dir);
make_plots(loaded_spec_nums);

cd(main_dir);