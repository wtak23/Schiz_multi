% addpath(genpath('./convenience'))
% addpath(genpath('./util'))
% addpath(genpath('./gridsearch'))
rootdir=fileparts(mfilename('fullpath'));
addpath(genpath(rootdir))
rmpath([rootdir,'/.git'])
%-------------------------------------------------------------------------%
% - these are subject list from old MDF files (02/10/2014)
%-------------------------------------------------------------------------%
rmpath([rootdir,'/data_local/autism_info/subjinfo_old'])
rmpath([rootdir,'/data_local/autism_info/subjinfo_ver1'])

%-------------------------------------------------------------------------%
% - to avoid the danger of accidentally using the old circmat files/scripts
%-------------------------------------------------------------------------%
rmpath([rootdir,'/util/diffmat_old'])

%-------------------------------------------------------------------------%
% - remove directory not of interest (02/27/2014)
%-------------------------------------------------------------------------%
rmpath(genpath([rootdir,'/ABIDE_3site_cv']))
rmpath(genpath([rootdir,'/ABIDE_3site_nested_10fold_cv']))
rmpath(genpath([rootdir,'/ABIDE_3site_nested_3fold_cv']))
rmpath(genpath([rootdir,'/Kfold_cv']))
rmpath(genpath([rootdir,'/nested_2fold_cv']))
rmpath(genpath([rootdir,'/single_site_CV']))
%%
format compact