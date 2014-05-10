%% may10_ttest_LDA.m
% (05/10/2014)
%=========================================================================%
% - Try LDA method on sMRI dataset (nfeat must be less than nsubs)
%=========================================================================%
%%
clear
purge
%% load data
load sMRI_design_censor.mat X y

[n,p]=size(X);

% scale to 0 mean, unit variance?
flag_scale = false;
if flag_scale
    X=zscore(X);
    load([get_rootdir,'/data_local/ttest_rank_idx_CV_zscaled.mat'],...
        'ttest_rank_idx_CV')
else
    load([get_rootdir,'/data_local/ttest_rank_idx_CV.mat'],...
        'ttest_rank_idx_CV')
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%%
% # features to prune via ttest
nprune = round(10)
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
    %% do ttest pruning
    Xtr = Xtr(:,ttest_rank_idx_CV{idxCV}(1:nprune));
    Xts = Xts(:,ttest_rank_idx_CV{idxCV}(1:nprune));
    
    %% prediction
    ypr = tak_LDA(Xtr,ytr,Xts,yts);
%     tak_binary_classification_summary(ypr,yts)
    ypredicted = [ypredicted;ypr];
    ytrue      = [ytrue; yts];
end % <- idxCV loop

classification_summary=tak_binary_classification_summary(ypredicted,ytrue)

