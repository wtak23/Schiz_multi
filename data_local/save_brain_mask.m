%% save_brain_mask
% (05/06/2014)
%=========================================================================%
% - save a mask of the brain (output: brain_mask.nii)
%=========================================================================%
%%
clear
purge

SubjDir = S_subjDir_Schiz_COBRE_censor;
SubjList = SubjDir(:,1);
% return
%%
dir_head = 'C:\Users\takanori\Desktop\Subjects/';
dir_tail = '/session_1/rest_1/coReg/';

%% initialize first nii struct
master = load_nii(strcat(dir_head,SubjDir{1},dir_tail,'m0wrp1mprage.nii'))
master.img = false(size(master.img));
% return
%% loop through all masks
for idx=1:length(SubjList)
    idx
    Subj_gm = load_nii(strcat(dir_head,SubjDir{idx},dir_tail,'m0wrp1mprage.nii'));
    Subj_wm = load_nii(strcat(dir_head,SubjDir{idx},dir_tail,'m0wrp2mprage.nii'));
    Subj_cf = load_nii(strcat(dir_head,SubjDir{idx},dir_tail,'m0wrp3mprage.nii'));
    
    master.img = (master.img | Subj_gm.img~=0 | Subj_wm.img~=0 | Subj_cf.img~=0);
end
view_nii(master)

% return
%%
master.hdr.dime.datatype=1; 
save_nii(master,'brain_mask.nii')

%%
