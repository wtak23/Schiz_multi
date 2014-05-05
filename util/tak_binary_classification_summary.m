function summary = tak_binary_classification_summary(ypred, ytrue)
% summary = tak_binary_classification_summary(ypred, ytrue,option)
% - report accuracy, TPR, TNR
%-------------------------------------------------------------------------%
% (02/16/2014) - added F1 score http://en.wikipedia.org/wiki/F1_score
%%
if length(ytrue)~= length(ypred)
    error('dimension mismatch')
end

ytrue=ytrue(:);
ypred=ypred(:);

n = size(ytrue,1);

%==================================================================================
% check if the labels are all +1 or -1
%==================================================================================
if n~=( sum(ytrue==1)+sum(ytrue==-1) ) || n~=( sum(ypred==1)+sum(ypred==-1) )
    warning(['The entries of ''ytrue'' and ''ypred'' must all be +1 or -1...',...
             'return only the overall accuracy'])
    summary.accuracy  = sum(ytrue==ypred)/n;
    return
end

% overall accuracy
summary.accuracy  = sum(ytrue==ypred)/n;

% 'p' for positive, 'n' for negative
idxp = (ytrue == +1);
idxn = (ytrue == -1);

%==================================================================================
% TP = true positives
% TN = true negatives
% FP = false positives
% FN = false negatives
%==================================================================================
TP = sum(ytrue(idxp)==ypred(idxp));
TN = sum(ytrue(idxn)==ypred(idxn));
FP = sum(ytrue(idxn)~=ypred(idxn));
FN = sum(ytrue(idxp)~=ypred(idxp));

%==================================================================================
% TPR = true positive rate  (aka sensitivity, recall, hit rate, power, detection rate)
% TNR = true negative rate  (aka specificity)
% FPR = false positive rate (aka size, type I error rate)
% FNR = false negative rate (aka miss rate, type II error rate, 1-TPR)
% PPV = positive predictive value (aka precision)
% NPV = negative predictive value
%==================================================================================
summary.TPR = TP/(TP+FN);
summary.TNR = TN/(TN+FP);

%=========================================================================%
% F1 score (02/16/2014)
%=========================================================================%
precision = TP/(TP+FP);
recall    = summary.TPR;
summary.F1 = 2*(precision*recall)/(precision+recall);