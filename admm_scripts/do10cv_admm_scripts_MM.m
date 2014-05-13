%% do10cv_admm_scripts_MM.m
% (05/13/2014)
%=========================================================================%
% - run admm scripts - evaluate accuracy via 10fold-CV
%=========================================================================%
%%
clear
purge
%% load data
load MM_design_censor.mat X y p1 p2

[n,p]=size(X);

% reorder data to cluster together indices for the -1 and +1 group
% [y,idx]=sort(y);
% X=X(idx,:);

% scale to 0 mean, unit variance?
% flag_scale = true;
flag_scale = false;
if flag_scale
    X=zscore(X);
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%% set algorithm options
%==========================================================================
% loss function
%==========================================================================
options.loss='hinge1';
% options.loss='hinge2';
% options.loss='hubhinge';
options.loss_huber_param=0.2; % <- only needed when using huberized-hinge

%==========================================================================
% set penalty parameters
%==========================================================================
% % penalty = 'enet'; % {'enet','gnet','flas','isoTV'}
% penalty = 'gnet';
% options.lambda=2^-10; % L1 penalty weight
% options.gamma =2^2; % second penalty weight

% % penalty = 'flas';
penalty = 'isoTV';
options.lambda=2^-11.5; % L1 penalty weight
options.gamma =2^-9.0; % second penalty weight

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
options.termin.progress = inf;   % <- display "progress" every k iterations
options.termin.silence = false; % <- display termination condition

%==========================================================================
% precompute the matrix K involved in the inversion lemma for updating w
%  - the form of the matrix to invert is: (ilemma1* X'*X + ilemma2*I)^-1
%==========================================================================
% precompute matrix K (optional): 
K=tak_admm_inv_lemma(X,options.rho/(options.rho+options.gamma));

%==========================================================================
% information needed for data augmentation and fft tricks
%==========================================================================
if ~strcmpi(penalty,'enet')
    
    %=====================================================================%
    % load graph and mask info for FC
    %=====================================================================%
    load graph_info347 coord
    load augmat_mask347newcirc A b

    options.misc.NSIZE1=[coord.NSIZE,coord.NSIZE];
    options.misc.A1=A; % <- augmentation matrix
    options.misc.b1=b; % <- masking vector
    clear A b coord 

    % preassigning this matrix C is optional: 
    % the admm script will compute it internally if the field doesn't exist
    % (helpful when doing CV, since creating this diffmat has minor overhead)
    options.misc.C1=tak_diffmat_newcirc(options.misc.NSIZE1,1); % <- C'*C has circulant structure!
    %%
    %=====================================================================%
    % load graph and mask info for sMRI
    %=====================================================================%
    % augmentation matrix
    load([get_rootdir,'/data_local/A_matrix_cropped.mat'],'A','nx','ny','nz')
    
    % mask vector
    load([get_rootdir,'/data_local/B_matrix_cropped.mat'],'b')

    options.misc.NSIZE2=[nx,ny,nz];
    options.misc.A2=A; % <- augmentation matrix
    options.misc.b2=b; % <- masking vector
    clear A b

    % preassigning this matrix C is optional: 
    % the admm script will compute it internally if the field doesn't exist
    % (helpful when doing CV, since creating this diffmat has minor overhead)
    options.misc.C2=tak_diffmat_newcirc(options.misc.NSIZE2,1); % <- C'*C has circulant structure!
    
    %=====================================================================%
    % feature size for FC (1) and sMRI (2)
    %=====================================================================%
    options.misc.p1 = p1;
    options.misc.p2 = p2;
end
%% begin 10-fold CV
ypredicted = [];
ytrue      = [];
tic_idxCV=tic;
for idxCV = 1:10
    fprintf('***** idxCV = %2d ...%6.3f sec *****\n',idxCV,toc(tic_idxCV))
    %======================================================================
    % 10-fold-CV data partition
    %======================================================================
    mask_ts = Overall.CrossValidFold(:,idxCV);
    mask_tr = ~mask_ts;
    
    Xts = X(mask_ts,:);
    Xtr = X(mask_tr,:);

    yts = y(mask_ts);
    ytr = y(mask_tr);
    
    %======================================================================
    % run ADMM
    %======================================================================
    switch penalty
        case 'enet'
            output=tak_admm_elasticnet(Xtr,ytr,options);
        case 'gnet'
            output=tak_admm_graphnet_MM(Xtr,ytr,options);
        case 'flas'
            output=tak_admm_fusedlasso_MM(Xtr,ytr,options);
        case 'isoTV'
            output=tak_admm_isotropicTV_MM(Xtr,ytr,options);
    end
    
    %=====================================================================% 
    % prediction on test data
    %=====================================================================%
    w=output.v2;
    NNZ(idxCV)=nnz(w);
    ypr=SIGN(Xts*w);

    tmp=tak_binary_classification_summary(ypr,yts);
    disp(num2str([tmp.accuracy, tmp.TPR, tmp.TNR, nnz(w)/1e3]))
    ypredicted = [ypredicted;ypr];
    ytrue      = [ytrue; yts];
end
NNZ
classification_summary=tak_binary_classification_summary(ypredicted,ytrue)
% return
%% run ADMM on full data
switch penalty
    case 'enet'
        output=tak_admm_elasticnet(X,y,options);
    case 'gnet'
        output=tak_admm_graphnet_MM(X,y,options);
    case 'flas'
        output=tak_admm_fusedlasso_MM(X,y,options);
    case 'isoTV'
        output=tak_admm_isotropicTV_MM(X,y,options);
end
v2=output.v2;
%% visualization
%% visualize FC part
%==========================================================================
% yeo network coordinate info (for visualization)
%==========================================================================
load yeo_info347_dilated5mm.mat yeoLabels roiMNI roiLabel
[idx_sort,labelCount] = tak_get_yeo_sort(roiLabel);

% circularly shift 1 indices
roiLabel=roiLabel-1;
roiLabel(roiLabel==-1)=12;

wcorrmat=tak_dvecinv(output.v2(1:p1),0);
wcorrmatsort=wcorrmat(idx_sort,idx_sort);

%-------------------------------------------------------------------------%
% some figure options
%-------------------------------------------------------------------------%
% cbar for the imtriag function
cbarOption={'fontsize',22','fontweight','b','ytick',[-.66,0,.66],...
    'YTickLabel',{' <0',' =0',' >0'},'TickLength',[0 0]};

% linewidth of the degree plots
lwidth_deg=2.5;

% text/line option for the line-boxes for the network partitioning
textOption1={'fontweight','b','fontsize',12};
lineOption = {'color','k','linewidth',0.5};

%=========================================================================%
% show figures
%=========================================================================%
figure,imexp
subplot(121),imtriag(wcorrmat),axis off,colorbar(cbarOption{:})
deg=sum(wcorrmat~=0);hold on,plot(347*ones(1,347)-deg,'k','linewidth',lwidth_deg)
subplot(122),imtriag(wcorrmatsort),axis off,colorbar(cbarOption{:})
deg=sum(wcorrmatsort~=0);hold on,plot(347*ones(1,347)-deg,'k','linewidth',lwidth_deg)
tak_local_linegroups3(gcf,labelCount,textOption1,yeoLabels,lineOption),hold on

figure,imexp
subplot(121),imcov(wcorrmat),axis off,caxis([-1,1] * max(abs(caxis))/5);
deg=sum(wcorrmat~=0);hold on,plot(347*ones(1,347)-deg,'k','linewidth',lwidth_deg)
subplot(122),imcov(wcorrmatsort),axis off,caxis([-1,1] * max(abs(caxis))/5);
deg=sum(wcorrmatsort~=0);hold on,plot(347*ones(1,347)-deg,'k','linewidth',lwidth_deg)
tak_local_linegroups3(gcf,labelCount,textOption1,yeoLabels,lineOption),hold on
%% visualize sMRI part
w_sMRI = output.v2(p1+1:p1+p2);
% purge
load([get_rootdir, '/data_local/A_matrix_fullFOV.mat'], 'A_full')
nii =tak_downsample_nii(load_nii([get_rootdir,'/data_local/m0wrp1mprage.nii']));
[nx,ny,nz]=size(nii.img);

%=========================================================================%
% create nii of the weight vector in the "volume space"
%=========================================================================%
wvol = reshape(A_full*w_sMRI, [nx,ny,nz]);

%-------------------------------------------------------------------------%
% set the regions outside the brain support to have the minimum 
% intensity value (improves visualization)
%-------------------------------------------------------------------------%
bmask=tak_downsample_nii(load_nii([get_rootdir,'/data_local/brain_mask.nii']));
bmask.img=logical(bmask.img);
% view_nii(bmask);
wvol(~bmask.img)=min(wvol(:));


%-------------------------------------------------------------------------%
% create nii version
%-------------------------------------------------------------------------%
nii_wvol = nii;
nii_wvol.img=wvol;

%=========================================================================%
% create thresholded mask volume of the weight vector
%=========================================================================%
%-------------------------------------------------------------------------%
% simple threshold by "epsilon"
%-------------------------------------------------------------------------%
% wvol_supp = zeros(size(wvol));
% wvol_supp(abs(wvol)>1e-3)=+1;

%-------------------------------------------------------------------------%
% threshold top "k" weights with largest magnitude
%-------------------------------------------------------------------------%
k=500000;
k=min(k,nnz(w_sMRI)); % <- incase k exceeds nnz of the weight vector
[w_rank,idx_rank]=sort(abs(w_sMRI),'descend');
tmp=zeros(size(w_sMRI));
tmp(idx_rank(1:k))=+1;
wvol_supp=reshape(A_full*tmp,[nx,ny,nz]);

%-------------------------------------------------------------------------%
% set background to -1
%-------------------------------------------------------------------------%
wvol_supp(~bmask.img)=-1;
% sum(wvol_supp(:)==1) % <- sanity check

%-------------------------------------------------------------------------%
% create nii version
%-------------------------------------------------------------------------%
nii_wvol_supp = nii;
nii_wvol_supp.img=wvol_supp;

%=========================================================================%
% visualize
%=========================================================================%
% view_nii(nii_wvol);
% view_nii(nii_wvol_supp);
vis3d(wvol, 'jet')
vis3d(wvol_supp, 'multi')