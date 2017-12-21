FEvox = 22;
CA_ip_vox = 2.75;
CA_op_vox = 5;



%convert CA pixels to FE pixels
[CAindex ] = find(CA_stack > 0) ;
[l,m,n]=size(CA_stack);
CAimagesize=[l,m,n];
clear l m n
[x,y,z] = ind2sub(CAimagesize, CAindex);

x_FE = round((x * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
y_FE = round((y * CA_ip_vox - CA_ip_vox/2 ) / FEvox );
z_FE = round((z * CA_op_vox - CA_op_vox/2 ) / FEvox );

%sub2ind



%convert FE pixels to CA pixels
[FEindex ] = find(FE_stack > 0) ;
[l,m,n]=size(FE_stack);
FEimagesize=[l,m,n];
clear l m n
[FEx,FEy,FEz] = ind2sub(FEimagesize, FEindex);
x = round((FEx * FEvox - FEvox/2)/ CA_ip_vox );
y = round((FEy * FEvox - FEvox/2)/ CA_ip_vox );
z = round((FEz * FEvox - FEvox/2)/ CA_op_vox );