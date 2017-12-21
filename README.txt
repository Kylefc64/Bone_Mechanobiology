%%%%%%%%%%%%%%%%%%%%%%% Summary of Overall Process %%%%%%%%%%%%%%%%%%%%%%%
1. Register CT DICOMs with Thresh_Resampled TIFFs
 - See KC Lab Notebook Entry for 2016-06-20 for detailed method using Amira
2. Register FEM SED images with Registered CT masks
 - See KC Lab notebook Entry for 2016-07-07 for detailed method using Amira
3. Combine the CT masks with the traced cancellous masks to create UV
images of cortical shells
4. Use the resulting images as well as previously processed images to
calculate Bonestats and save binary masks of the endosteal and periosteal surfaces
5. Use these binary masks to associate SED with bone formation at the
endosteal and periosteal surfaces and to generate easily visualizeable data
in the form of histograms (and maybe other plots)

Run Cortical_Processing_Master.m to complete steps 3, 4, and 5.
Make sure to change necessary parameters so that the correct specimens are processed
and so that the program knows the correct size of each image stack.
The function make_plots.m may need to be altered to obtain desired data.