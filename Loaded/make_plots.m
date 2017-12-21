function make_plots(spec_names)

%spec_names = {'53', '54', '57', '58', '62', '65', '70', '71'};
%spec_names = {'53', '54', '57', '58', '70', '71'};
%num_highres_slices = [1199,1198,1088,1198,1199,1199,1198,1199];
%num_lowres_slices = [273,273,248,273,273,273,273,273];
num_specs = size(spec_names, 2);
num_regs = 3;


for j = 1:num_regs
    roi{j} = ['ROI', num2str(j)];
end


All_perio_BF = [];
All_perio_non_BF = [];
All_endo_BF = [];
All_endo_non_BF = [];

All_perio_SED = [];
All_endo_SED = [];

%%% plot for all specimens combined %%%

spec_perio_edge_SEDs = []; %ROI 1, 2, 3...
spec_endo_edge_SEDs = []; %ROI 1, 2, 3...
spec_perio_edge_BFVs = []; %ROI 1, 2, 3...
spec_endo_edge_BFVs = []; %ROI 1, 2, 3...
spec_BFV_indss = []; %ROI 1, 2, 3...
spec_non_BFV_indss = []; %ROI 1, 2, 3...
%BFVs = []; %%%%%%%%%%%%%%%%%

for i = 1:num_specs
    
    perio_edge_SEDs = []; %ROI 1, 2, 3...
    endo_edge_SEDs = []; %ROI 1, 2, 3...
    perio_edge_BFVs = []; %ROI 1, 2, 3...
    endo_edge_BFVs = []; %ROI 1, 2, 3...
    %BFV_indss = []; %ROI 1, 2, 3...
    %non_BFV_indss = []; %ROI 1, 2, 3...
    
    %%% plot for all ROIs of one specimen %%%
    spec_name = spec_names{i};
    message = ['Creating histograms for specimen R', spec_name, ' ...\n'];
    fprintf(message);
    for j = 1:num_regs
        
        %%% plot for each individual ROI in each specimen %%%
        img_data_path = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R',spec_name,'_C8_Processed\SED_Data\','HistData_R', spec_name, '_', roi{j},'.mat'] ;
        load(img_data_path);
        
        %Periosteal BF and non_BF vs strain values
        %Normal histogram
        perio_fig = figure;
        subplot(2,1,1)
        hold off
        clear BFV_inds;
        BFV_inds = find(BFV == 1);
        non_BFV_inds = find(BFV == 0);
        %Possible fits: 'weibill', 'gamma', 'gev', 'logistic', 'lognormal', tlocatioscale'
        h1 = histfit((nonzeros(perio_edge_SED(BFV_inds) / 1000)), 100, 'kernel');
        hold on
        h2 = histfit((nonzeros(perio_edge_SED(non_BFV_inds) / 1000)), 100, 'kernel');
        hold on
        alpha 0.3
        
        legend('Bone forming locations','Bone forming locations fitted curve', ...
            'Non-bone forming locations','Non-bone forming locations fitted curve');
        xlabel('Strain Energy Density (kPa)');
        ylabel('Number of Locations');
        title(['Specimen R', spec_name, ' ', roi{j}, ' Periosteal BF and non BF vs Strain Energy Density']);
        set(h1(1),'facecolor','g');
        set(h2(1),'facecolor','b');
        set(h1(2),'color','g')
        set(h2(2),'color','b')
        
        %Log histogram
        subplot(2,1,2)
        hold off
        non_BFV_inds = find(BFV == 0);
        h3 = histfit(log(nonzeros(perio_edge_SED(BFV_inds))), 100, 'kernel');
        hold on
        h4 = histfit(log(nonzeros(perio_edge_SED(non_BFV_inds))), 100, 'kernel');
        hold on
        alpha 0.3
        
        legend('Bone forming locations','Bone forming locations fitted curve', ...
            'Non-bone forming locations','Non-bone forming locations fitted curve', 'Location', 'Northwest');
        xlabel('Log( Strain Energy Density (Pa))');
        ylabel('Number of Locations');
        title(['Specimen R', spec_name, ' ', roi{j}, ' Periosteal BF and non BF vs Log( Strain Energy Density )']);
        set(h3(1),'facecolor','g');
        set(h4(1),'facecolor','b');
        set(h3(2),'color','g')
        set(h4(2),'color','b')
        
        saveDir = ['\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R', spec_name, '_C8_Processed\SED_Data\Figures\'];
        if isdir(saveDir)==0; mkdir(saveDir); end
        saveas(perio_fig, [saveDir, 'Perio_fig_R', spec_name, '_', roi{j}, '.fig']);
        %savefig(perio_fig, [saveDir, 'Perio_fig_R', spec_name, '_', roi{j}, '.fig']);
        
        
        
        %Endosteal BF and non_BF vs strain values
        %Normal histogram
        endo_fig = figure;
        subplot(2,1,1)
        hold off
        non_BFV_inds = find(BFV == 0);
        h5 = histfit((nonzeros(endo_edge_SED(BFV_inds) / 1000)), 100, 'kernel');
        hold on
        h6 = histfit((nonzeros(endo_edge_SED(non_BFV_inds) / 1000)), 100, 'kernel');
        hold on
        alpha 0.3
        
        legend('Bone forming locations','Bone forming locations fitted curve', ...
            'Non-bone forming locations','Non-bone forming locations fitted curve');
        xlabel('Strain Energy Density (kPa)');
        ylabel('Number of Locations');
        title(['Specimen R', spec_name, ' ', roi{j}, ' Endosteal BF and non BF vs Strain Energy Density']);
        set(h5(1),'facecolor','g');
        set(h6(1),'facecolor','b');
        set(h5(2),'color','g')
        set(h6(2),'color','b')
        
        %Log histogram
        subplot(2,1,2)
        hold off
        non_BFV_inds = find(BFV == 0);
        h7 = histfit(log(nonzeros(endo_edge_SED(BFV_inds))), 100, 'kernel');
        hold on
        h8 = histfit(log(nonzeros(endo_edge_SED(non_BFV_inds))), 100, 'kernel');
        hold on
        alpha 0.3
        
        legend('Bone forming locations','Bone forming locations fitted curve', ...
            'Non-bone forming locations','Non-bone forming locations fitted curve', 'Location', 'Northwest');
        xlabel('Log( Strain Energy Density (Pa))');
        ylabel('Number of Locations');
        title(['Specimen R', spec_name, ' ', roi{j}, ' Endosteal BF and non BF vs Log( Strain Energy Density )']);
        set(h7(1),'facecolor','g');
        set(h8(1),'facecolor','b');
        set(h7(2),'color','g')
        set(h8(2),'color','b')
        
        %savefig(endo_fig, [saveDir, 'Endo_fig_R', spec_name, '_', roi{j}, '.fig']);
        saveas(endo_fig, [saveDir, 'Endo_fig_R', spec_name, '_', roi{j}, '.fig']);
        
        
        %Concatenate image stacks of all ROIs for each specimen
        %http://www.mathworks.com/help/matlab/ref/cat.html
        perio_SED_size(j) = size(perio_edge_SED, 3);
        perio_BFV_size(j) = size(perio_edge_BFV, 3);
        endo_SED_size(j) = size(endo_edge_SED, 3);
        endo_BFV_size(j) = size(endo_edge_BFV, 3);
        if j == 1
            perio_edge_SEDs = perio_edge_SED;
            perio_edge_BFVs = perio_edge_BFV;
            endo_edge_SEDs = endo_edge_SED;
            endo_edge_BFVs = endo_edge_BFV;
        else
            perio_edge_SEDs = cat(3,perio_edge_SEDs, perio_edge_SED);
            perio_edge_BFVs = cat(3,perio_edge_BFVs, perio_edge_BFV);
            endo_edge_SEDs = cat(3,endo_edge_SEDs, endo_edge_SED);
            endo_edge_BFVs = cat(3,endo_edge_BFVs, endo_edge_BFV);
            
            
            close all;
            
            if j == 3
                %mn_perio_bf = mean(nonzeros(perio_edge_SED(BFV_inds)))
                %md_perio_bf = median(nonzeros(perio_edge_SED(BFV_inds)))
                %mn_perio_non_bf = mean(nonzeros(perio_edge_SED(non_BFV_inds)))
                %md_perio_non_bf = median(nonzeros(perio_edge_SED(non_BFV_inds)))
                %mn_endo_bf = mean(nonzeros(endo_edge_SED(BFV_inds)))
                %md_endo_bf = median(nonzeros(endo_edge_SED(BFV_inds)))
                %mn_endo_non_bf = mean(nonzeros(endo_edge_SED(non_BFV_inds)))
                %md_endo_non_bf = median(nonzeros(endo_edge_SED(non_BFV_inds)))
                
                %fprintf(['Specimen R', spec_name, ' ROI 3 ...\n']);
                %geo_mn_perio_bf = geomean(nonzeros(perio_edge_SED(BFV_inds)))
                %geo_mn_perio_non_bf = geomean(nonzeros(perio_edge_SED(non_BFV_inds)))
                %geo_mn_endo_bf = geomean(nonzeros(endo_edge_SED(BFV_inds)))
                %geo_mn_endo_non_bf = geomean(nonzeros(endo_edge_SED(non_BFV_inds)))
            end
        end
    end
    
    %%%%%%%%%% Histograms for the entire specimen (combined ROIs)%%%%%%%%%%%
    perio_BFV_indss = find(perio_edge_BFVs == 1);
    endo_BFV_indss = find(endo_edge_BFVs == 1);
    perio_non_BFV_indss = find(perio_edge_BFVs == 0);
    endo_non_BFV_indss = find(endo_edge_BFVs == 0);
    
    fprintf(['Specimen R', spec_name, ' Combined ...\n']);
    %geo_mn_perio_bf = geomean(nonzeros(perio_edge_SEDs(perio_BFV_indss)))
    %geo_mn_perio_non_bf = geomean(nonzeros(perio_edge_SEDs(perio_non_BFV_indss)))
    %geo_mn_endo_bf = geomean(nonzeros(endo_edge_SEDs(endo_BFV_indss)))
    %geo_mn_endo_non_bf = geomean(nonzeros(endo_edge_SEDs(endo_non_BFV_indss)))
    geo_mn_perio = geomean(nonzeros(perio_edge_SEDs))
    geo_mn_endo = geomean(nonzeros(endo_edge_SEDs))
    
    %Combined specimens histogram data
    All_perio_SED = cat(1,All_perio_SED, nonzeros(perio_edge_SEDs));
    All_endo_SED = cat(1,All_endo_SED, nonzeros(endo_edge_SEDs));
    
    All_perio_BF = cat(1,All_perio_BF, nonzeros(perio_edge_SEDs(perio_BFV_indss)));
    All_endo_BF = cat(1,All_endo_BF, nonzeros(endo_edge_SEDs(endo_BFV_indss)));
    All_perio_non_BF = cat(1,All_perio_non_BF, nonzeros(perio_edge_SEDs(perio_non_BFV_indss)));
    All_endo_non_BF = cat(1,All_endo_non_BF, nonzeros(endo_edge_SEDs(endo_non_BFV_indss)));
    
    
    
    
    %Normal histogram
    perio_vs_endo_SED_fig = figure;
    subplot(2,1,1)
    hold off
    %Possible fits: 'weibill', 'gamma', 'gev', 'logistic', 'lognormal', tlocatioscale'
    h1 = histfit(nonzeros(perio_edge_SEDs), 100, 'kernel');
    hold on
    h2 = histfit(nonzeros(endo_edge_SEDs), 100, 'kernel');
    hold on
    alpha 0.3
    
    legend('Periosteal SED','Periosteal SED fitted curve', ...
        'Endosteal SED','Endosteal SED fitted curve');
    xlabel('Strain Energy Density (kPa)');
    ylabel('Number of Locations');
    title('Periosteal vs Endosteal Strain Energy Density');
    set(h1(1),'facecolor','g');
    set(h2(1),'facecolor','b');
    set(h1(2),'color','g')
    set(h2(2),'color','b')
    
    %Log histogram
    subplot(2,1,2)
    hold off
    h3 = histfit(log(nonzeros(perio_edge_SEDs)), 100, 'kernel');
    hold on
    h4 = histfit(log(nonzeros(endo_edge_SEDs)), 100, 'kernel');
    hold on
    alpha 0.3
    
    legend('Periosteal SED','Periosteal SED fitted curve', ...
        'Endosteal SED','Endosteal SED fitted curve', 'Location', 'Northwest');
    xlabel('Log( Strain Energy Density (Pa))');
    ylabel('Number of Locations');
    title('Specimen Periosteal vs Endosteal Log( Strain Energy Density )');
    set(h3(1),'facecolor','g');
    set(h4(1),'facecolor','b');
    set(h3(2),'color','g')
    set(h4(2),'color','b')
    
    %saveDir = '\\Biomech-10\i\RTL06_Cortical_Processed\';
    %saveas(perio_vs_endo_SED_fig, [saveDir, 'perio_vs_endo_SED.fig']);
    
    
    
    
    
    
    %Periosteal BF and non_BF vs strain values
    %Normal histogram
    spec_perio_fig = figure;
    subplot(2,1,1)
    hold off
    %Possible fits: 'weibill', 'gamma', 'gev', 'logistic', 'lognormal', tlocatioscale'
    h1 = histfit((nonzeros(perio_edge_SEDs(perio_BFV_indss) / 1000)), 100, 'kernel');
    hold on
    h2 = histfit((nonzeros(perio_edge_SEDs(perio_non_BFV_indss) / 1000)), 100, 'kernel');
    hold on
    alpha 0.3
    
    legend('Bone forming locations','Bone forming locations fitted curve', ...
        'Non-bone forming locations','Non-bone forming locations fitted curve');
    xlabel('Strain Energy Density (kPa)');
    ylabel('Number of Locations');
    title(['Specimen R', spec_name, ' Periosteal BF and non BF vs Strain Energy Density']);
    set(h1(1),'facecolor','g');
    set(h2(1),'facecolor','b');
    set(h1(2),'color','g')
    set(h2(2),'color','b')
    
    %Log histogram
    subplot(2,1,2)
    hold off
    h3 = histfit(log(nonzeros(perio_edge_SEDs(perio_BFV_indss))), 100, 'kernel');
    hold on
    h4 = histfit(log(nonzeros(perio_edge_SEDs(perio_non_BFV_indss))), 100, 'kernel');
    hold on
    alpha 0.3
    
    legend('Bone forming locations','Bone forming locations fitted curve', ...
        'Non-bone forming locations','Non-bone forming locations fitted curve', 'Location', 'Northwest');
    xlabel('Log( Strain Energy Density (Pa))');
    ylabel('Number of Locations');
    title(['Specimen R', spec_name, ' Periosteal BF and non BF vs Log( Strain Energy Density )']);
    set(h3(1),'facecolor','g');
    set(h4(1),'facecolor','b');
    set(h3(2),'color','g')
    set(h4(2),'color','b')
    
    saveas(perio_fig, [saveDir, 'Perio_fig_R', spec_name, '.fig']);
    
    
    
    %Endosteal BF and non_BF vs strain values
    %Normal histogram
    spec_endo_fig = figure;
    subplot(2,1,1)
    hold off
    h5 = histfit((nonzeros(endo_edge_SEDs(endo_BFV_indss) / 1000)), 100, 'kernel');
    hold on
    h6 = histfit((nonzeros(endo_edge_SEDs(endo_non_BFV_indss) / 1000)), 100, 'kernel');
    hold on
    alpha 0.3
    
    legend('Bone forming locations','Bone forming locations fitted curve', ...
        'Non-bone forming locations','Non-bone forming locations fitted curve');
    xlabel('Strain Energy Density (kPa)');
    ylabel('Number of Locations');
    title(['Specimen R', spec_name, ' Endosteal BF and non BF vs Strain Energy Density']);
    set(h5(1),'facecolor','g');
    set(h6(1),'facecolor','b');
    set(h5(2),'color','g')
    set(h6(2),'color','b')
    
    %Log histogram
    subplot(2,1,2)
    hold off
    h7 = histfit(log(nonzeros(endo_edge_SEDs(endo_BFV_indss))), 100, 'kernel');
    hold on
    h8 = histfit(log(nonzeros(endo_edge_SEDs(endo_non_BFV_indss))), 100, 'kernel');
    hold on
    alpha 0.3
    
    legend('Bone forming locations','Bone forming locations fitted curve', ...
        'Non-bone forming locations','Non-bone forming locations fitted curve', 'Location', 'Northwest');
    xlabel('Log( Strain Energy Density (Pa))');
    ylabel('Number of Locations');
    title(['Specimen R', spec_name, ' Endosteal BF and non BF vs Log( Strain Energy Density )']);
    set(h7(1),'facecolor','g');
    set(h8(1),'facecolor','b');
    set(h7(2),'color','g')
    set(h8(2),'color','b')
    
    %savefig(endo_fig, [saveDir, 'Endo_fig_R', spec_name, '_', roi{j}, '.fig']);
    saveas(endo_fig, [saveDir, 'Endo_fig_R', spec_name, '.fig']);
    
    
    close all;
    
end

%Histograms for all specimens combined

fprintf('All Specimens Combined ...\n');
%geo_mn_perio_bf = geomean(All_perio_BF)
%geo_mn_perio_non_bf = geomean(All_perio_non_BF)
%geo_mn_endo_bf = geomean(All_endo_BF)
%geo_mn_endo_non_bf = geomean(All_endo_non_BF)
geo_mn_perio = geomean(nonzeros(All_perio_SED))
geo_mn_endo = geomean(nonzeros(All_endo_SED))

%{
max_perio = max(All_perio_SED);
max_endo = max(All_endo_SED);
binranges = [];
i = 0;
while i < max([max_perio, max_endo])
    binranges = cat(1, binranges, i);
    i = i + 100;
end
[N,edges] = histcounts(All_perio_SED,100)
max_perio = max(N);
[N,edges] = histcounts(All_endo_SED,100)
max_endo = max(N);
%}

%Normal histogram
perio_vs_endo_SED_fig = figure;
subplot(2,1,1)
hold off
%Possible fits: 'weibill', 'gamma', 'gev', 'logistic', 'lognormal', tlocatioscale'
h1 = histfit(All_perio_SED, 100, 'kernel');
hold on
h2 = histfit(All_endo_SED, 100, 'kernel');
hold on
alpha 0.3

legend('Periosteal SED','Periosteal SED fitted curve', ...
    'Endosteal SED','Endosteal SED fitted curve');
xlabel('Strain Energy Density (kPa)');
ylabel('Number of Locations');
title('Combined Periosteal vs Endosteal Strain Energy Density');
set(h1(1),'facecolor','g');
set(h2(1),'facecolor','b');
set(h1(2),'color','g')
set(h2(2),'color','b')

%Log histogram
subplot(2,1,2)
hold off
h3 = histfit(log(All_perio_SED), 100, 'kernel');
hold on
h4 = histfit(log(All_endo_SED), 100, 'kernel');
hold on
alpha 0.3

legend('Periosteal SED','Periosteal SED fitted curve', ...
    'Endosteal SED','Endosteal SED fitted curve', 'Location', 'Northwest');
xlabel('Log( Strain Energy Density (Pa))');
ylabel('Number of Locations');
title('Combined Periosteal vs Endosteal Log( Strain Energy Density )');
set(h3(1),'facecolor','g');
set(h4(1),'facecolor','b');
set(h3(2),'color','g')
set(h4(2),'color','b')

saveDir = '\\Biomech-10\i\RTL06_Cortical_Processed\';
saveas(perio_vs_endo_SED_fig, [saveDir, 'perio_vs_endo_SED.fig']);




%Periosteal BF and non_BF vs strain values
%Normal histogram
Combined_perio_fig = figure;
subplot(2,1,1)
hold off
%Possible fits: 'weibill', 'gamma', 'gev', 'logistic', 'lognormal', tlocatioscale'
h1 = histfit((All_perio_BF / 1000), 100, 'kernel');
hold on
h2 = histfit((All_perio_non_BF / 1000), 100, 'kernel');
hold on
alpha 0.3

legend('Bone forming locations','Bone forming locations fitted curve', ...
    'Non-bone forming locations','Non-bone forming locations fitted curve');
xlabel('Strain Energy Density (kPa)');
ylabel('Number of Locations');
title('Combined Periosteal BF and non BF vs Strain Energy Density');
set(h1(1),'facecolor','g');
set(h2(1),'facecolor','b');
set(h1(2),'color','g')
set(h2(2),'color','b')

%Log histogram
subplot(2,1,2)
hold off
h3 = histfit(log(All_perio_BF), 100, 'kernel');
hold on
h4 = histfit(log(All_perio_non_BF), 100, 'kernel');
hold on
alpha 0.3

legend('Bone forming locations','Bone forming locations fitted curve', ...
    'Non-bone forming locations','Non-bone forming locations fitted curve', 'Location', 'Northwest');
xlabel('Log( Strain Energy Density (Pa))');
ylabel('Number of Locations');
title('Combined Periosteal BF and non BF vs Log( Strain Energy Density )');
set(h3(1),'facecolor','g');
set(h4(1),'facecolor','b');
set(h3(2),'color','g')
set(h4(2),'color','b')

saveDir = '\\Biomech-10\i\RTL06_Cortical_Processed\';
saveas(Combined_perio_fig, [saveDir, 'Perio_fig_Combined.fig']);



%Endosteal BF and non_BF vs strain values
%Normal histogram
Combined_endo_fig = figure;
subplot(2,1,1)
hold off
h5 = histfit((All_endo_BF / 1000), 100, 'kernel');
hold on
h6 = histfit((All_endo_non_BF / 1000), 100, 'kernel');
hold on
alpha 0.3

legend('Bone forming locations','Bone forming locations fitted curve', ...
    'Non-bone forming locations','Non-bone forming locations fitted curve');
xlabel('Strain Energy Density (kPa)');
ylabel('Number of Locations');
title('Combined Endosteal BF and non BF vs Strain Energy Density');
set(h5(1),'facecolor','g');
set(h6(1),'facecolor','b');
set(h5(2),'color','g')
set(h6(2),'color','b')

%Log histogram
subplot(2,1,2)
hold off
h7 = histfit(log(All_endo_BF), 100, 'kernel');
hold on
h8 = histfit(log(All_endo_non_BF), 100, 'kernel');
hold on
alpha 0.3

legend('Bone forming locations','Bone forming locations fitted curve', ...
    'Non-bone forming locations','Non-bone forming locations fitted curve', 'Location', 'Northwest');
xlabel('Log( Strain Energy Density (Pa))');
ylabel('Number of Locations');
title('Combined Endosteal BF and non BF vs Log( Strain Energy Density )');
set(h7(1),'facecolor','g');
set(h8(1),'facecolor','b');
set(h7(2),'color','g')
set(h8(2),'color','b')

saveas(Combined_endo_fig, [saveDir, 'Endo_fig_Combined.fig']);

close all;