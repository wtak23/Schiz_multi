% addpath(genpath('./convenience'))
% addpath(genpath('./util'))
% addpath(genpath('./gridsearch'))
rootdir=fileparts(mfilename('fullpath'));
addpath(genpath(rootdir))
rmpath([rootdir,'/.git'])

%-------------------------------------------------------------------------%
% - to avoid the danger of accidentally using the old circmat files/scripts
%-------------------------------------------------------------------------%
rmpath([rootdir,'/util/diffmat_old'])

%-------------------------------------------------------------------------%
% - remove directory not of interest (02/27/2014)
%-------------------------------------------------------------------------%
%%
format compact