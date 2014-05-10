%% gridsearch_NB_PCA_plotResults
% (05/10/2014)
%=========================================================================%
% - plot results from gridsearch_NB_PCA.m
%=========================================================================%
%%
clear
purge
fsavefig=true;

%% load data
% scale to 0 mean, unit variance?
flag_scale = true;

if flag_scale
    dataPath=[get_rootdir,'/classification_results/gridsearch_NB_PCA_zscaled.mat'];
    outFig=[get_rootdir,'/classification_results/gridsearch_NB_PCA_zscaled'];
else
    dataPath=[get_rootdir,'/classification_results/gridsearch_NB_PCA.mat'];
    outFig=[get_rootdir,'/classification_results/gridsearch_NB_PCA'];
end
dataVars={'accuracy','TPR', 'TNR','F1','numPC_list','mFileName','timeStamp'};
load(dataPath,dataVars{:})
%%
YLIM=[0.2,1];
lwid=4;
fsize=16;
screenSize = [10 100 700 500];
figure,set(gcf,'Units','pixels','Position', screenSize)
plot(numPC_list,accuracy,'b','LineWidth',lwid),ylim(YLIM),grid on, hold on
plot(numPC_list,TPR,'r','LineWidth',lwid)
plot(numPC_list,TNR,'g','LineWidth',lwid)
xlabel('Num PCs','fontsize',fsize,'fontweight','b')
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