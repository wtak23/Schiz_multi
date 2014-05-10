%% may10_run_admm_enet
%=========================================================================%
% - elastic net script
%=========================================================================%
%%
clear
purge
%% load data
load sMRI_design_censor.mat X y

[n,p]=size(X);
[n,p]=size(X);

% reorder data to cluster together indices for the -1 and +1 group
[y,idx]=sort(y);
X=X(idx,:);

% scale to 0 mean, unit variance?
flag_scale = false;
if flag_scale
    X=zscore(X);
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
% load Overall Overall
%% set algorithm options
%==========================================================================
% loss function
%==========================================================================
options.loss='hinge1';
% options.loss='hinge2';
% options.loss='hubhinge';
% options.loss_huber_param=0.2; % <- only needed when using huberized-hinge

%==========================================================================
% set penalty parameters
%==========================================================================
penalty = 'enet'; % {'enet','gnet','flas','isoTV'}
% penalty = 'gnet';
options.lambda=2^-9; % L1 penalty weight
options.gamma =2^-3; % second penalty weight

% % penalty = 'flas';
% penalty = 'isoTV';
% options.lambda=2^-8.5; % L1 penalty weight
% options.gamma =2^-10.5; % second penalty weight

% lambda=2^-9;
% rho = 0.5;
% options.lambda=lambda*rho; % L1 penalty weight
% options.gamma =lambda*(1-rho); % second penalty weight

%==========================================================================
% augmented lagrangian parameters
%==========================================================================
options.rho=1;

%==========================================================================
% termination criterion
%==========================================================================
options.termin.maxiter = 400;   % <- maximum number of iterations
options.termin.tol = 5e-3;      % <- relative change in the primal variable
options.termin.progress = 25;   % <- display "progress" (every k iterations...set to inf to disable)
options.termin.silence = false; % <- display termination condition

%==========================================================================
% information needed for data augmentation and fft tricks
%==========================================================================
if ~strcmpi(penalty,'enet')
%     load graph_info347 adjmat coord
%     load augmat_mask347newcirc A b
% 
%     options.misc.NSIZE=[coord.NSIZE,coord.NSIZE];
%     options.misc.A=A; % <- augmentation matrix
%     options.misc.b=b; % <- masking vector
% 
%     % preassigning this matrix C is optional: 
%     % the admm script will compute it internally if the field doesn't exist
%     % (helpful when doing CV, since creating this diffmat has minor overhead)
%     C=tak_diffmat_newcirc(options.misc.NSIZE,1); % <- C'*C has circulant structure!
%     options.misc.C=C;
end
%% run ADMM
switch penalty
    case 'enet'
        output=tak_admm_elasticnet(X,y,options);
    case 'gnet'
        output=tak_admm_stl_graphnet(X,y,options);
    case 'flas'
        output=tak_admm_stl_fusedlasso(X,y,options);
    case 'isoTV'
        output=tak_admm_stl_isotropicTV(X,y,options);
end
%%
% purge
w=output.w;
v1=output.v1;
v2=output.v2;

% number of iteration it took to converge
k=output.k;

% nnz_w=nnz(w)
nnz_v2=nnz(v2)

% ypred=sign(X*v2);
ypred=SIGN(X*v2);
YX=diag(y)*X;

figure,imexp
% primal variables and residuals
subplot(261),tplot(log10(output.rel_changevec))
subplot(268),tplot(y)
subplot(269),tplot(ypred)
subplot(264),tplot(w)
subplot(265),tplot(v1),% ylim([-.6 .6])
subplot(266),tplot(v2),% ylim([-.6 .6])
subplot(2,6,11),tplot(YX*w-v1),title('resid1 (YXw-v1)')
subplot(2,6,12),tplot(w-v2),title('resid2 (w-v2)')
tak_binary_classification_summary(ypred,y)
%% visualization
load([get_rootdir, '/data_local/A_matrix_fullFOV.mat'], 'A_full')
nii =tak_downsample_nii(load_nii([get_rootdir,'/data_local/m0wrp1mprage.nii']));
[nx,ny,nz]=size(nii.img);

%=========================================================================%
% create nii of the weight vector in the "volume space"
%=========================================================================%
wvol = reshape(A_full*output.v2, [nx,ny,nz]);
nii_wvol = nii;
nii_wvol.img=wvol;

view_nii(nii_wvol)
showcs3(wvol)