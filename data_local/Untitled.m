clear
purge
mask = load_nii([get_rootdir,'/data_local/brain_mask.nii']);
%%
master.hdr.dime.datatype=1; 
mask.img=logical(mask.img);
save_nii(mask,[get_rootdir,'/data_local/brain_mask.nii'])