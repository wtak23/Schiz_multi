%% liblinear_10cv.m
% (05/08/2014)
% - run cross validation
%%
clear all; 
close all;
drawnow
%% load data
load sMRI_design_censor.mat X y
% load sMRI_design_censor_fullRes.mat X y
% load sMRI_design_censor_dsamp4.mat X y

[n,p]=size(X);

%==========================================================================
% load info for the indexing for the 10-fold-CV partitioning
%==========================================================================
load Overall Overall
%% set algorithm options
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
    
    %======================================================================
    % run libinear
    %======================================================================
%     output=train(ytr,sparse(Xtr),'-s 3 -c 1 -w1 1 -w-1 1 -q -B -1');
    output=train(ytr,sparse(Xtr),'-s 6 -c 10 -q');

%     keyboard
    %======================================================================
    % analyze admm result
    %======================================================================
    w=output.w(:);
%     nnz(w)
    % prediction on the testing data
    ypr=SIGN(Xts*w);
%     Xts2=[Xts, ones(length(yts),1)];
%     ypr=SIGN(Xts2*w);
    
%     tak_binary_classification_summary(ypr,yts)
    ypredicted = [ypredicted;ypr];
    ytrue      = [ytrue; yts];
    
end % <- idxCV loop

classification_summary=tak_binary_classification_summary(ypredicted,ytrue)