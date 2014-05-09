%% may08_backproject_ver2.m
% (05/08/2014)
%=========================================================================%
% - "Backproject" loosely means to map from vectorized-mask back to brain volume
%=========================================================================%
%%
clear
purge
dir_head = 'C:\Users\takanori\Desktop\Subjects/';
dir_tail = '/session_1/rest_1/coReg/';

nii = load_nii(strcat(dir_head,'0040000',dir_tail,'m0wrp1mprage.nii'));
nii.img(isnan(nii.img))=0;
nii.img=double(nii.img);

mask_nii = load_nii([get_rootdir,'/data_local/brain_mask.nii']);
nii=tak_downsample_nii(nii);
mask_nii=tak_downsample_nii(mask_nii);
mask_nii.img=logical(mask_nii.img);

nii_masked=nii;
nii_masked.img = nii.img.*mask_nii.img;

mask = mask_nii.img;

% return
%%
% view_nii(nii)
% view_nii(nii_masked)
% view_nii(mask)
%% extract feature vector via masking
x = nii.img(mask_nii.img);
p = length(x);
[nx,ny,nz]=size(nii.img);
x2 = mask.*nii.img;
% x2=x2(:);

mask_vec=mask(:);

load([get_rootdir,'/data_local/A_matrix'],'A')
%%
X=reshape(A*x,[nx,ny,nz]);
nii_masked_recon = nii_masked;
nii_masked_recon.img = X;

isequal(nii_masked,nii_masked_recon)
isequal(nii_masked.img,X)

x_recon = A'*X(:);
isequal(x,x_recon)
% view_nii(nii_masked)
% view_nii(nii_masked_recon)