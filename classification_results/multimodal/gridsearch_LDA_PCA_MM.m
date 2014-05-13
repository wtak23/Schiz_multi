%% gridsearch_LDA_PCA_MM.m
% (05/12/2014)
%=========================================================================%
% - Try LDA method on FC+sMRI dataset using PC loadings
%-------------------------------------------------------------------------%
% - gridsearch over # PCs
% - code mostly from may10_LDA_PCA.m
%=========================================================================%
%%
clear
purge

fsave=true;
%% load data
load MM_design_censor.mat y

% scale to 0 mean, unit variance?
flag_scale = 0;
if flag_scale
    load([get_rootdir,'/data_local/multimodal/PCA.mat'],'X')
else
    load([get_rootdir,'/data_local/multimodal/PCA_zscaled.mat'],'X')
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%% num PC grid
numPC_list = 1:1:100;
numPC_length = length(numPC_list)
%% results to save
accuracy = zeros(numPC_length,1);
TPR = zeros(numPC_length,1);
TNR = zeros(numPC_length,1);
F1 = zeros(numPC_length,1);

if flag_scale
    outPath=[get_rootdir,'/classification_results/multimodal/results/gridsearch_LDA_PCA_zscaled.mat'];
else
    outPath=[get_rootdir,'/classification_results/multimodal/results/gridsearch_LDA_PCA.mat'];
end
outVars={'accuracy','TPR', 'TNR','F1','numPC_list','mFileName','timeStamp'};
%% begin grid search
tic_idx=tic;

Xoriginal=X;
for idx_PCs = 1:numPC_length
    fprintf('***** idx_ttest = %2d ...%6.3f sec *****\n',...
        idx_PCs,toc(tic_idx))
    %---------------------------------------------------------------------% 
    % extract PCs
    %---------------------------------------------------------------------% 
    num_PCs= numPC_list(idx_PCs);
    X = Xoriginal(:,1:num_PCs);
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

        %% prediction
        ypr = tak_LDA(Xtr,ytr,Xts,yts);

    %     tak_binary_classification_summary(ypr,yts)
        ypredicted = [ypredicted;ypr];
        ytrue      = [ytrue; yts];
    end % <- idxCV loop
    classification_summary=tak_binary_classification_summary(ypredicted,ytrue)
    accuracy(idx_PCs)=classification_summary.accuracy;
    TPR(idx_PCs)=classification_summary.TPR;
    TNR(idx_PCs)=classification_summary.TNR;
    F1(idx_PCs)=classification_summary.F1;
end

%% save
mFileName=mfilename;
timeStamp=tak_timestamp;

if fsave
    save(outPath,outVars{:})
end
