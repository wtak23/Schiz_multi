%% gridsearch_liblinear_L2_ttest.m
% (05/10/2014)
%=========================================================================%
% - Try L2-penalized SVM from liblinear + ttest pruningon sMRI dataset
%-------------------------------------------------------------------------%
% - grid search over C parameter and nPrune over ttest (2-d grid search)
% - code mostly from may10_L2liblinear_ttest.m
%=========================================================================%
%%
clear
purge

fsave=true;
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
ttestList = round(2.^(2:0.2:16))
ttestLength = length(ttestList)

% C parameter for liblinear
CList = 2.^(-6:0.25:20)
CLength = length(CList)
% return
%% results to save
accuracy = zeros(CLength,ttestLength);
TPR = zeros(CLength,ttestLength);
TNR = zeros(CLength,ttestLength);
F1 = zeros(CLength,ttestLength);

if flag_scale
    outPath=[get_rootdir,'/classification_results/gridsearch_liblinear_L2_ttest_zscaled.mat'];
else
    outPath=[get_rootdir,'/classification_results/gridsearch_liblinear_L2_ttest2.mat'];
end
outVars={'accuracy','TPR', 'TNR','F1','ttestList','CList','mFileName','timeStamp'};
%% new!!!  indexing design matrix is time consuming, so create cell list
Xtr_list = cell(10,1);
Xts_list = cell(10,1);
for idxCV = 1:10 
    idxCV
    %======================================================================
    % 10-fold-CV data partition
    %======================================================================
    mask_ts = Overall.CrossValidFold(:,idxCV);
    mask_tr = ~mask_ts;

    Xts_list{idxCV} = X(mask_ts,:);
    Xtr_list{idxCV} = X(mask_tr,:);
end
% return
%% begin grid search
tic_idx=tic;
for idx_C = 1:CLength
    fprintf('***** idx_ttest = %2d ...%6.3f sec *****\n',...
        idx_C,toc(tic_idx))
    C = CList(idx_C);
    log2(C)
    for idx_ttest = 1:ttestLength
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

%             Xts = X(mask_ts,:);
%             Xtr = X(mask_tr,:);
            Xts = Xts_list{idxCV};
            Xtr = Xtr_list{idxCV};

            yts = y(mask_ts);
            ytr = y(mask_tr);

            %% do ttest pruning
            Xtr = Xtr(:,ttest_rank_idx_CV{idxCV}(1:num_ttest));
            Xts = Xts(:,ttest_rank_idx_CV{idxCV}(1:num_ttest));
            
            %=====================================================================%
            % run liblinear
            %=====================================================================%
            output=train(ytr,sparse(Xtr),['-s 6 -c ',num2str(C),' -q']);        
            w=output.w(:);
            %% prediction
            ypr=SIGN(Xts*w);
            ypredicted = [ypredicted;ypr];
            ytrue      = [ytrue; yts];
        end % <- idxCV loop
        classification_summary=tak_binary_classification_summary(ypredicted,ytrue)
        accuracy(idx_C,idx_ttest)=classification_summary.accuracy;
        TPR(idx_C,idx_ttest)=classification_summary.TPR;
        TNR(idx_C,idx_ttest)=classification_summary.TNR;
        F1(idx_C,idx_ttest)=classification_summary.F1;
    end
end

%% save
mFileName=mfilename;
timeStamp=tak_timestamp;

if fsave
    save(outPath,outVars{:})
end