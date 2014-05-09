%% may08_get_diffmat.m
% (05/08/2014)
%=========================================================================%
% - Try to construct finite differencing matrix "C"
%=========================================================================%
%%
clear
purge
dir_head = 'C:\Users\takanori\Desktop\Subjects/';
dir_tail = '/session_1/rest_1/coReg/';

load([get_rootdir,'/data_local/A_matrix'],'A')

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
% % view_nii(nii)
% view_nii(nii_masked)
% view_nii(mask_nii)
% return
%% extract feature vector via masking
X = nii.img;
x = X(mask);
p = length(x);
[nx,ny,nz]=size(nii.img);
P = numel(nii.img);
% isequal(x,A'*nii_masked.img(:))
% tak_gui_show_slices(X)
% showcs3(X)
%% create (P x 3) matrix indicating the (x,y,z) coordinate of X
[xx,yy,zz]=ndgrid(1:nx,1:ny,1:nz);
coord.X=zeros(P,3);
coord.X(:,1)=xx(:);
coord.X(:,2)=yy(:);
coord.X(:,3)=zz(:);
coord.X_x=xx;
coord.X_y=yy;
coord.X_z=zz;

%-------------------------------------------------------------------------%
% sanity checks
%-------------------------------------------------------------------------%
% X_xcoord_nii=nii;
% X_ycoord_nii=nii;
% X_zcoord_nii=nii;
% X_xcoord_nii.img=xx;
% X_ycoord_nii.img=yy;
% X_zcoord_nii.img=zz;
% view_nii(X_xcoord_nii)
% view_nii(X_ycoord_nii)
% view_nii(X_zcoord_nii)
% for ix=1:nx
%     unique(squeeze(xx(ix,:,:)))
% end
% for iy=1:ny
%     unique(squeeze(yy(:,iy,:)))
% end
% for iz=1:nz
%     unique(squeeze(zz(:,:,iz)))
% end
% for i = 1:P
%     coord(i,1)=
% end
%% create (p x 3) matrix indicating the (x,y,z) coordinate of x

%=========================================================================%
% - r: indexing of the 3d coordinate
%=========================================================================%
coord.r = zeros(p,3);
coord.r(:,1)=A'*xx(:);
coord.r(:,2)=A'*yy(:);
coord.r(:,3)=A'*zz(:);

%-------------------------------------------------------------------------%
% sanity check based on looking at "coord.r" through the "variable editor"
% and looking at "mask_nii" seems to confirm my scripts is working correctly
%-------------------------------------------------------------------------%
% view_nii(mask_nii)

%% apply the same brute force scheme as t_get_347_graphinfo.m in my old project
%% create a nearest-neighbor graph in 3d...do it brute force
adjmat=sparse(p,p);
timeTotal=tic;
tic
for i=1:p
    if mod(i,2000)==0; i,toc, end;
    
    % find the index-set of the 1st order nearest neighbor
    idx_NN=sum(abs(bsxfun(@minus, coord.r, coord.r(i,:))),2)==1;
    
    %% sanity checks
%     sum(idx_NN)
%     if sum(idx_NN)==6
%         coord.r(i,:)
%         [coord.r(idx_NN,:)]
%         keyboard
%     end
    %%
    % nearest-neighbors
    adjmat(i,idx_NN)=1;
    
    %=====================================================================%
    % sanity check of the nearest neighbor property...
    % - the selected neighboring edge-sets should have l1 distance of 1 
    %   wrt the in (x,y,z) coordinate in question
    %=====================================================================%
    dist_set=abs(sum(bsxfun(@minus,coord.r(idx_NN==1,:),coord.r(i,:)),2));
    if ~all(bsxfun(@eq, dist_set, 1))
        error('argh..')
    end
end
C=tak_adjmat2incmat(adjmat);
%%
