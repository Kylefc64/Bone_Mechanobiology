function [result] = find_p_in_range(matrix, start_rng, end_rng)
%finds probably of bone formation within a specified range of strain values

%matrix is a nx3 dimensional matrix with histogram values for
%bone formation and strain values 
%For example, if matrix = [12345,75,35;27534,102,67;23745,167,122],
%then 75 pixels have strain 12345, 102 pixels have strain 27534, 167 pixels
%have strain 23745, and 35/75 pixels at a strain of 12345 formed bone,
%67/102 pixels at a strain of 27534 formed bone, and 122/167 pixels at a
%strain of 23745 formed bone

matrix_sorted = sortrows(matrix); %sort the matrix in ascending order
%find matrix_sorted indices of start_rng and end_rng
start_idx = find(matrix_sorted(:,1) == start_rng);
end_idx = find(matrix_sorted(:,1) == end_rng);

num_pix_in_rng = 0;
num_BF_in_rng = 0;
for i = start_idx:end_idx
    if matrix_sorted(i,1) >= start_rng && matrix_sorted(i,1) <= end_rng
        num_pix_in_rng = num_pix_in_rng + matrix_sorted(i,2);
        num_BF_in_rng = num_BF_in_rng + matrix_sorted(i,3);
    end
end

result = num_BF_in_rng / num_pix_in_rng;
end