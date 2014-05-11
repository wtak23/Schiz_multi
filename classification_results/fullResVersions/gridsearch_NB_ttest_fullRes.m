%% gridsearch_NB_ttest_fullRes.m
% (05/10/2014)
%=========================================================================%
% - Try naive-bayes LDA method on sMRI dataset
%-------------------------------------------------------------------------%
% - grid search over ttest pruning
% - code mostly from may10_ttest_NB.m
%=========================================================================%
%%
clear
purge

fsave=true;
%% load data
load sMRI_design_censor_fullRes.mat X y

[n,p]=size(X);

% scale to 0 mean, unit variance?
flag_scale = true;
if flag_scale
    X=zscore(X);
    load([get_rootdir,'/data_local/ttest_rank_idx_CV_zscaled_fullRes.mat'],...
        'ttest_rank_idx_CV')
else
    load([get_rootdir,'/data_local/ttest_rank_idx_CV_fullRes.mat'],...
        'ttest_rank_idx_CV')
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%%
% # features to prune via ttest
ttestList = round(2.^(2:0.5:19))
ttestLength = length(ttestList)
%% results to save
accuracy = zeros(ttestLength,1);
TPR = zeros(ttestLength,1);
TNR = zeros(ttestLength,1);
F1 = zeros(ttestLength,1);

if flag_scale
    outPath=[get_rootdir,'/classification_results/fullResVersions',...
        '/results/gridsearch_NB_ttest_zscaled_fullRes.mat'];
else
    outPath=[get_rootdir,'/classification_results/fullResVersions',...
        '/results/gridsearch_NB_ttest_fullRes.mat'];
end
outVars={'accuracy','TPR', 'TNR','F1','ttestList','mFileName','timeStamp'};
%% begin grid search
tic_idx_ttest=tic;
for idx_ttest = 1:ttestLength
    fprintf('***** idx_ttest = %2d ...%6.3f sec *****\n',...
        idx_ttest,toc(tic_idx_ttest))
    num_ttest = ttestList(idx_ttest);
    %% begin 10-fold CV
    ypredicted = [];
    ytrue      = [];
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
        Xtr = Xtr(:,ttest_rank_idx_CV{idxCV}(1:num_ttest));
        Xts = Xts(:,ttest_rank_idx_CV{idxCV}(1:num_ttest));
        %% prediction
        ypr = tak_LDA_indep(Xtr,ytr,Xts,yts);
        ypredicted = [ypredicted;ypr];
        ytrue      = [ytrue; yts];
    end % <- idxCV loop
    classification_summary=tak_binary_classification_summary(ypredicted,ytrue)
    accuracy(idx_ttest)=classification_summary.accuracy;
    TPR(idx_ttest)=classification_summary.TPR;
    TNR(idx_ttest)=classification_summary.TNR;
    F1(idx_ttest)=classification_summary.F1;
end

%% save
mFileName=mfilename;
timeStamp=tak_timestamp;

if fsave
    save(outPath,outVars{:})
end