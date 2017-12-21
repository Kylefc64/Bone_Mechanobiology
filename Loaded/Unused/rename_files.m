function rename_files()

dir = '\\Biomech-10\i\RTL06_Cortical_Processed\RTL06_R54_C8_Processed\CT_binary_registered\';

begin_index = 0;
end_index = 1197;

while(begin_index <= end_index)
   oldName = ['R54_C8_Binary_Mask', num2str(begin_index, '%04d'), '.tif'];
   newName = ['CT_Binary_Registered_', num2str(begin_index , '%04d'), '.tif'];
   filePath = [dir, oldName];
   image = imread(filePath);
   filePath = [dir, newName];
   imwrite(image, filePath);
   begin_index = begin_index + 1;
end