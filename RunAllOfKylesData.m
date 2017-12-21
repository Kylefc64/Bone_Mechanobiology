%list = {'53', '54', '57', '58', '62', '65', '66', '69', '70', '71', '55', '56'};
list = {'71'};

for rats = 1:size(list, 1)
    PostLoad_BF_method3_cortical(list{rats}); 
end

%Run_Functions_Consecutively()
