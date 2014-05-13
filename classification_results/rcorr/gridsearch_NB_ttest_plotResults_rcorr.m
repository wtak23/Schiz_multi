%% gridsearch_NB_ttest_plotResults_rcorr
% (05/12/2014)
%=========================================================================%
% - plot results from gridsearch_NB_ttest.m
%=========================================================================%
%%
clear
purge
fsavefig=true;

%% load data
% scale to 0 mean, unit variance?
flag_scale = 1;

if flag_scale
    dataPath=[get_rootdir,'/classification_results/rcorr/results/gridsearch_NB_ttest_zscaled.mat'];
    outFig=[get_rootdir,'/classification_results/rcorr/results/gridsearch_NB_ttest_zscaled'];
else
    dataPath=[get_rootdir,'/classification_results/rcorr/results/gridsearch_NB_ttest.mat'];
    outFig=[get_rootdir,'/classification_results/rcorr/results/gridsearch_NB_ttest'];
end
dataVars={'accuracy','TPR', 'TNR','F1','ttestList','mFileName','timeStamp'};
load(dataPath,dataVars{:})
%%
YLIM=[0.2,1];
lwid=4;
fsize=16;
screenSize = [10 100 700 500];
figure,set(gcf,'Units','pixels','Position', screenSize)
plot(log2(ttestList),accuracy,'b','LineWidth',lwid),ylim(YLIM),grid on, hold on
plot(log2(ttestList),TPR,'r','LineWidth',lwid)
plot(log2(ttestList),TNR,'g','LineWidth',lwid)
xlabel('log_2(nfeatures)','fontsize',fsize,'fontweight','b')
set(gca,'fontsize',fsize,'fontweight','b')
hleg=legend('Accuracy','TPR','TNR','location','best')
set(hleg,'fontsize',fsize,'fontweight','b')

if fsavefig
    savefig(outFig,'png')
end
% plot(log2(ttestList),F1,'b','LineWidth',2),ylim(YLIM),grid on
% subplot(221),tplot(log2(ttestList),accuracy),title('accuracy'),ylim(YLIM)
% subplot(222),tplot(log2(ttestList),F1),title('F1'),ylim(YLIM)
% subplot(223),tplot(log2(ttestList),TPR),title('TPR'),ylim(YLIM)
% subplot(224),tplot(log2(ttestList),TNR),title('TNR'),ylim(YLIM)