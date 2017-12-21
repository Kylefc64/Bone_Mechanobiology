function [start_slice, end_slice] = RTL06_RegionOfInterest_Cortical(spec_name, ROI)

if strcmp(spec_name , '53') && strcmp(ROI , 'ROI1')
    start_slice = 251;
    end_slice = 510;
elseif strcmp(spec_name , '53') && strcmp(ROI , 'ROI2')
    start_slice =770 ;
    end_slice = 1029;
elseif strcmp(spec_name , '53') && strcmp(ROI , 'ROI3')
    start_slice =511;
    end_slice = 769;
elseif strcmp(spec_name , '54')&& strcmp(ROI , 'ROI1')
    start_slice = 182;
    end_slice = 441;
elseif strcmp(spec_name , '54') && strcmp(ROI , 'ROI2')
    start_slice = 690;
    end_slice = 949;
elseif strcmp(spec_name , '54') && strcmp(ROI , 'ROI3')
    start_slice = 442;
    end_slice = 689;
    
elseif strcmp(spec_name , '55')&& strcmp(ROI , 'ROI1')
    start_slice = 103;
    end_slice = 362;
elseif strcmp(spec_name , '55') && strcmp(ROI , 'ROI2')
    start_slice = 473;
    end_slice = 732;
elseif strcmp(spec_name , '55') && strcmp(ROI , 'ROI3')
    start_slice = 363;
    end_slice = 472;
    
elseif strcmp(spec_name , '56')&& strcmp(ROI , 'ROI1')
    start_slice = 186;
    end_slice = 445;
elseif strcmp(spec_name , '56') && strcmp(ROI , 'ROI2')
    start_slice = 670;
    end_slice = 929;
elseif strcmp(spec_name , '56') && strcmp(ROI , 'ROI3')
    start_slice = 446;
    end_slice = 669;
    
elseif strcmp(spec_name , '57')&& strcmp(ROI , 'ROI1')
    start_slice = 150;
    end_slice = 409;
elseif strcmp(spec_name , '57') && strcmp(ROI , 'ROI2')
    start_slice = 660;
    end_slice = 919;
elseif strcmp(spec_name , '57') && strcmp(ROI , 'ROI3')
    start_slice = 410;
    end_slice = 659;
    
elseif strcmp(spec_name , '58')&& strcmp(ROI , 'ROI1')
    start_slice = 190;
    end_slice = 449;
elseif strcmp(spec_name , '58') && strcmp(ROI , 'ROI2')
    start_slice = 700;
    end_slice = 959;
elseif strcmp(spec_name , '58') && strcmp(ROI , 'ROI3')
    start_slice = 450;
    end_slice = 699;
    
elseif strcmp(spec_name , '62')&& strcmp(ROI , 'ROI1')
    start_slice = 131;
    end_slice = 390;
elseif strcmp(spec_name , '62') && strcmp(ROI , 'ROI2')
    start_slice = 671;
    end_slice = 930;
elseif strcmp(spec_name , '62') && strcmp(ROI , 'ROI3')
    start_slice = 391;
    end_slice = 670;
elseif strcmp(spec_name , '65')&& strcmp(ROI , 'ROI1')
    start_slice = 136;
    end_slice = 395;
elseif strcmp(spec_name , '65') && strcmp(ROI , 'ROI2')
    start_slice = 661;
    end_slice = 920;
elseif strcmp(spec_name , '65') && strcmp(ROI , 'ROI3')
    start_slice = 396;
    end_slice = 660;
elseif strcmp(spec_name , '66')&& strcmp(ROI , 'ROI1')
    start_slice = 192;
    end_slice = 451;
elseif strcmp(spec_name , '66') && strcmp(ROI , 'ROI2')
    start_slice = 710;
    end_slice = 969;
elseif strcmp(spec_name , '66') && strcmp(ROI , 'ROI3')
    start_slice = 452;
    end_slice = 709;
    
elseif strcmp(spec_name , '69')&& strcmp(ROI , 'ROI1')
    start_slice = 183;
    end_slice = 442;
elseif strcmp(spec_name , '69') && strcmp(ROI , 'ROI2')
    start_slice = 550;
    end_slice = 809;
elseif strcmp(spec_name , '69') && strcmp(ROI , 'ROI3')
    start_slice = 443;
    end_slice = 549;    
    
elseif strcmp(spec_name , '70')&& strcmp(ROI , 'ROI1')
    start_slice = 155;
    end_slice = 414;
elseif strcmp(spec_name , '70') && strcmp(ROI , 'ROI2')
    start_slice = 651;
    end_slice = 910;
elseif strcmp(spec_name , '70') && strcmp(ROI , 'ROI3')
    start_slice = 415;
    end_slice = 650;
elseif strcmp(spec_name , '71')&& strcmp(ROI , 'ROI1')
    start_slice = 220;
    end_slice = 479;
elseif strcmp(spec_name , '71') && strcmp(ROI , 'ROI2')
    start_slice = 720;
    end_slice = 979;
elseif strcmp(spec_name , '71') && strcmp(ROI , 'ROI3')
    start_slice = 480;
    end_slice = 719;
end