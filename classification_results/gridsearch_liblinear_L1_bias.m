%% gridsearch_liblinear_L1_bias.m
% (05/10/2014)
%=========================================================================%
% - Try L1 penalized logistic regression from liblinear
% - bias/offset term included
%-------------------------------------------------------------------------%
% - grid search over C parameter
% - code mostly from liblinear_10cv.m
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
end

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%%
CList = 2.^(-6:20)
CLength = length(CList)
%% results to save
accuracy = zeros(CLength,1);
TPR = zeros(CLength,1);
TNR = zeros(CLength,1);
F1 = zeros(CLength,1);
NNZ = zeros(CLength,1);

if flag_scale
    outPath=[get_rootdir,'/classification_results/gridsearch_liblinear_bias_zscaled.mat'];
else
    outPath=[get_rootdir,'/classification_results/gridsearch_liblinear_bias.mat'];
end
outVars={'accuracy','TPR', 'TNR','F1','NNZ','CList','mFileName','timeStamp'};
%% begin grid search
tic_idx=tic;
for idx_C = 1:CLength
    fprintf('***** idx_ttest = %2d ...%6.3f sec *****\n',...
        idx_C,toc(tic_idx))
    C = CList(idx_C);
    log2(C)
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
        %=====================================================================%
        % run liblinear
        %=====================================================================%
        output=train(ytr,sparse(Xtr),['-s 6 -c ',num2str(C),' -q  -B 1']);        
        w=output.w(:);
        %% prediction
%         ypr=SIGN([Xts, ones(length(yts),1)]*w);
        ypr=predict(yts,sparse(Xts),output,'-q');
        ypredicted = [ypredicted;ypr];
        ytrue      = [ytrue; yts];
    end % <- idxCV loop
    classification_summary=tak_binary_classification_summary(ypredicted,ytrue)
    accuracy(idx_C)=classification_summary.accuracy;
    TPR(idx_C)=classification_summary.TPR;
    TNR(idx_C)=classification_summary.TNR;
    F1(idx_C)=classification_summary.F1;
    NNZ(idx_C)=nnz(w);
end

%% save
mFileName=mfilename;
timeStamp=tak_timestamp;

if fsave
    save(outPath,outVars{:})
end