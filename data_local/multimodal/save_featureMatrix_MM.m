%% save_featureMatrix_MM.m
% (05/12/2014)
%=========================================================================%
% save multimodal design matrix
%=========================================================================%
%%
clear
purge
%% load data
load rcorr_design_censor.mat X y
X1=X;
load sMRI_design_censor.mat X y
X2=X;
X=[X1,X2];


%% save
timeStamp=tak_timestamp;
mFileName=mfilename;
save([get_rootdir,'/data_local/multimodal/MM_design_censor.mat'],'X','y','mFileName','timeStamp')
%%
% purge
% Xstd=zscore(X);
% figure,imagesc(X)
% figure,imagesc(Xstd)