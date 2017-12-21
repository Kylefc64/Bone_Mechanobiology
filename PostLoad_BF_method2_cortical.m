function PostLoad_BF_method2_cortical(spec_num)
%Specimen is just the number, inputted as a string.
%homeDir is the computer and drive where gray images of FITC are located,
%inputted as a string.
%Example of homeDir input '\\Biomech-15\g\'

%code purpose - uses thresholded CA and OXY labels, removes any CA objects
%that are near OXY object, leaving a stack of images that are only post
%loading formation events.

%Written by Erin Cresswell
%Last modified July 27, 2016

%% Inputs
% spec_num = '62';
saveDir = '\\Biomech-10\i\' ;
homeDir = '\\Biomech-10\i\';
voxel_size = 2.75;

%% Set up the full specimen name
specimen = ['RTL06_R', spec_num,'_C8_Processed'];

%% Set up all the working directories
codeDir = '\\Biomech-10\i\MatlabCode\Cortical\';

FITCDir = [homeDir  'RTL06_Cortical_Processed\' specimen '\CA_cortical_thresh\'];
OXYDir = [homeDir  'RTL06_Cortical_Processed\' specimen '\Oxy_cortical_thresh\'];

outDir1 = [saveDir 'RTL06_Cortical_Processed\' specimen '\PostLoading_BF_method2\'];
if ~isdir(outDir1); mkdir(outDir1); end
outDir2 = [saveDir 'RTL06_Cortical_Processed\' specimen '\PreLoading_only_BF_method2\'];
if ~isdir(outDir2); mkdir(outDir2); end
outDir3 = [saveDir 'RTL06_Cortical_Processed\' specimen '\PreLoading_continued_BF_method2\'];
if ~isdir(outDir3); mkdir(outDir3); end
%% Save this m file in the folder with the created images
current_file_path = mfilename('fullpath');
current_file_name = mfilename;
copyfile(strcat(current_file_path, '.m'), strcat(outDir1, current_file_name, '.m'));
copyfile(strcat(current_file_path, '.m'), strcat(outDir2, current_file_name, '.m'));
copyfile(strcat(current_file_path, '.m'), strcat(outDir3, current_file_name, '.m'));
%% Import the FITC and TRITC filenames

% FITC image
cd(FITCDir);
fitcFil = dir('*CA*.tif');

% TRITC image
cd(OXYDir);
oxyFil = dir('*OXY*.tif');

cd(codeDir)

%% Gather each Thresholded slice
fprintf('Thresholding Specimen')
display(spec_num)


%prealocate memory for the thresholded array
part = round( length(oxyFil)/4 );

for loop = 1:4
    %read in all the images
    tic
    
image1 = imread([OXYDir oxyFil(1).name]);
[x,y] = size(image1);
oxy_stack = zeros(x, y, part-3);
fitc_stack = zeros(x, y, part-3);
    
    if loop ==1
        for count = 1: part ;
            oxy  = imread([OXYDir  oxyFil(count).name]);
            fitc = imread([FITCDir fitcFil(count).name]);
            oxy_stack(:,:,count) = oxy;
            fitc_stack(:,:,count) = fitc;
            display(count)
            clear oxy fitc
        end
    elseif loop == 2
        for count = 1: part ;
            oxy  = imread([OXYDir  oxyFil(part+count).name]);
            fitc = imread([FITCDir fitcFil(part+count).name]);
            oxy_stack(:,:,count) = oxy;
            fitc_stack(:,:,count) = fitc;
            display(count)
            clear oxy fitc
        end
    elseif loop == 3
        for count = 1: part ;
            oxy  = imread([OXYDir  oxyFil(2*part+count).name]);
            fitc = imread([FITCDir fitcFil(2*part+count).name]);
            oxy_stack(:,:,count) = oxy;
            fitc_stack(:,:,count) = fitc;
            display(count)
            clear oxy fitc
        end
    elseif loop == 4
        left = length(oxyFil) - 3*part; 
        for count = 1: left ;
            oxy  = imread([OXYDir  oxyFil(3*part+count).name]);
            fitc = imread([FITCDir fitcFil(3*part+count).name]);
            oxy_stack(:,:,count) = oxy;
            fitc_stack(:,:,count) = fitc;
            display(count)
            clear oxy fitc
        end
    end
    toc
    
    clear  image1 x y
    %% label the fitc stack objects, dilate the oxy objects, remove all fitc objects overlapping oxy
    
    %do a 3D closing of both data set
    if voxel_size == 2.75
        radius = 5;
    elseif voxel_size == 0.714
        radius = 19;
    end
    SE_3D = strel(ones(radius,radius,ceil(radius/2)));
    
    fprintf('3D closing fitc')
    tic
    fitc_close = imclose(logical(fitc_stack),SE_3D);
    toc
    clear fitc_stack
    
    fprintf('3D closing oxy')
    tic
    oxy_close = imclose(logical(oxy_stack),SE_3D);
    toc
    clear oxy_stack
    
    
    %  remove really small formation events
    CA_cc=bwconncomp(fitc_close,26);
    numPixels = cellfun(@numel,CA_cc.PixelIdxList);
    num_removed_CA  = 0;
    for k=1:length(numPixels)
        %Filter out stuff too small
        if numPixels(k) <= 264
            fitc_close(CA_cc.PixelIdxList{k}) = 0;
            num_removed_CA = num_removed_CA +1;
        end
    end
    clear *cc num* k
    
    OXY_cc=bwconncomp(oxy_close,26);
    numPixels = cellfun(@numel,OXY_cc.PixelIdxList);
    num_removed_OXY  = 0;
    for k=1:length(numPixels)
        %Filter out stuff too small
        if numPixels(k) <= 264
            oxy_close(OXY_cc.PixelIdxList{k}) = 0;
            num_removed_OXY = num_removed_OXY +1;
        end
    end
    clear *cc num* k
    
    % find the overlap and declare each event pre, contin, or post
    FITC_labeled = bwlabeln(fitc_close,26);
    OXY_labeled = bwlabeln(oxy_close,26);
    
    Oxy_di = imdilate(oxy_close,SE_3D);
    Fitc_di = imdilate(fitc_close,SE_3D);
    clear SE* 
    
    Pre_loadCont_events = zeros(size(FITC_labeled));
    
    FITC_obj2remove = unique(nonzeros(double(Oxy_di) .* FITC_labeled ));
    clear Oxy_di
    
    OXY_obj2remove = unique(nonzeros(double(Fitc_di) .* OXY_labeled ));
    clear Fitc_di
    
    
    if length(FITC_obj2remove) ~= length(OXY_obj2remove)
        warning('WARNING: Inconsistant number or Continued Loading Events found')
    end
    
    num2remove = length(FITC_obj2remove);
    for i = 1: num2remove
        ind = find(FITC_labeled == FITC_obj2remove(i));
        fitc_close(ind) = 0;
        Pre_loadCont_events(ind) = 1;
        clear ind
    end
    clear FITC_lab* FITC_ob* i num2remove
    
    num2remove = length(OXY_obj2remove);
    for i = 1: num2remove
        ind = find(OXY_labeled == OXY_obj2remove(i));
        oxy_close(ind) = 0;
        Pre_loadCont_events(ind) = 1;
        clear ind
    end
    clear OXY_lab* OXY_ob* i num2remove
    
    %% Gather easy BF data
    % BFdata{2,1} = 'Preloading Only';
    % BFdata{3,1} = 'Preloading Cont';
    % BFdata{4,1} = 'Postloading';
    % OXY_cc=bwconncomp(oxy_close,26);
    % CA_cc=bwconncomp(fitc_close,26);
    % both_cc=bwconncomp(Pre_loadCont_events,26);
    %
    % BFdata{1,2} = 'Number of Events';
    % BFdata{2,2} = OXY_cc.NumObjects;
    % BFdata{3,2} = both_cc.NumObjects;
    % BFdata{4,2} = CA_cc.NumObjects;
    %
    % BFdata{1,3} = 'Total Formation Volume';
    % BFdata{2,3} = sum(sum(sum(oxy_close)));
    % BFdata{3,3} = sum(sum(sum(Pre_loadCont_events)));
    % BFdata{4,3} = sum(sum(sum(fitc_close)));
    
    
    %% Write the images out as a stack of Tiffs
    fprintf('Writing out stack of images')
    tic
    fitc_close = im2uint8(fitc_close);   %this format can be opened in image j
    Pre_loadCont_events = im2uint8(Pre_loadCont_events);
    oxy_close = im2uint8(oxy_close);
       
    for count= 1:size(fitc_close,3)
        if loop ==1
            slice_num = count ;
        elseif loop ==2
            slice_num = part + count ;
        elseif loop ==3
            slice_num = 2*part + count ;
        elseif loop ==4
            slice_num = 3*part + count ;
        end
        slice = ['0000' num2str(slice_num)];
        slice = slice(end-3:end);
        
        imwrite(fitc_close(:,:,count),          [outDir1 slice '_PostL_BF.tif' ]);
        imwrite(oxy_close(:,:,count),           [outDir2 slice '_PreLOnly_BF.tif' ]);
        imwrite(Pre_loadCont_events(:,:,count), [outDir3 slice '_PreLCont_BF.tif' ]);
    end
    toc
end
fprintf('\n Thresholding finished on')
display(spec_num)

