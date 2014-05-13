%% gridsearch_liblinear_L2_ttest_plotResults_MM
% (05/12/2014)
%=========================================================================%
% - plot results from gridsearch_liblinear_L2_ttest.m
%=========================================================================%
%%
clear
purge
fsavefig=true;

%% load data
% scale to 0 mean, unit variance?
flag_scale = 0;

if flag_scale
    dataPath=[get_rootdir,'/classification_results/multimodal',...
        '/results/gridsearch_liblinear_L2_ttest_zscaled.mat'];
    outFig=[get_rootdir,'/classification_results/multimodal',...
        '/results/gridsearch_liblinear_L2_ttest_zscaled'];
else
    dataPath=[get_rootdir,'/classification_results/multimodal',...
        '/results/gridsearch_liblinear_L2_ttest.mat'];
    outFig=[get_rootdir,'/classification_results/multimodal',...
        '/results/gridsearch_liblinear_L2_ttest'];
end
dataVars={'accuracy','TPR', 'TNR','F1','ttestList','CList'};
load(dataPath,dataVars{:})
%%
fsize=13;
screenSize = [10 100 1777 400];
figure,set(gcf,'Units','pixels','Position', screenSize)
subplot(131), imagesc(log2(CList),log2(ttestList),accuracy'), colorbar, impixelinfo
    xlabel('log_2(C)','fontsize',fsize,'fontweight','b')
    ylabel('log_2(npruned)','fontsize',fsize,'fontweight','b')
    set(gca,'fontsize',fsize,'fontweight','b')
    title('Accuracy','fontsize',fsize,'fontweight','b')
subplot(132), imagesc(log2(CList),log2(ttestList),TPR'), colorbar, impixelinfo
    xlabel('log_2(C)','fontsize',fsize,'fontweight','b')
    ylabel('log_2(npruned)','fontsize',fsize,'fontweight','b')
    set(gca,'fontsize',fsize,'fontweight','b')
    title('TPR','fontsize',fsize,'fontweight','b')
subplot(133), imagesc(log2(CList),log2(ttestList),TNR'), colorbar, impixelinfo
    xlabel('log_2(C)','fontsize',fsize,'fontweight','b')
    ylabel('log_2(npruned)','fontsize',fsize,'fontweight','b')
    set(gca,'fontsize',fsize,'fontweight','b')
    title('TNR','fontsize',fsize,'fontweight','b')

if fsavefig
    savefig(outFig,'png')
end