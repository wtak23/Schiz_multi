%% may10_LDA_PCA.m
% (05/10/2014)
%=========================================================================%
% - Try LDA method on sMRI dataset using PC loadings
%=========================================================================%
%%
clear
purge
%% load data
load sMRI_design_censor.mat y

% scale to 0 mean, unit variance?
flag_scale = false;
if flag_scale
    load([get_rootdir,'/data_local/PCA.mat'],'X')
else
    load([get_rootdir,'/data_local/PCA_zscaled.mat'],'X')
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%%
% # features to prune via ttest
num_PCs= 14;
X = X(:,1:num_PCs);
%% begin 10-fold CV
ypredicted = [];
ytrue      = [];
tic_idxCV=tic;
for idxCV = 1:10
%     fprintf('***** idxCV = %2d ...%6.3f sec *****\n',idxCV,toc(tic_idxCV))
    %======================================================================
    % 10-fold-CV data partition
    %======================================================================
    mask_ts = Overall.CrossValidFold(:,idxCV);
    mask_tr = ~mask_ts;
    
    Xts = X(mask_ts,:);
    Xtr = X(mask_tr,:);

    yts = y(mask_ts);
    ytr = y(mask_tr);

    %% prediction
    ypr = tak_LDA(Xtr,ytr,Xts,yts);
    
%     tak_binary_classification_summary(ypr,yts)
    ypredicted = [ypredicted;ypr];
    ytrue      = [ytrue; yts];
end % <- idxCV loop

classification_summary=tak_binary_classification_summary(ypredicted,ytrue)

