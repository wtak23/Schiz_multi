function B = tak_circmask_newcirc(ARRAYSIZE)
% B = tak_circmask_newcirc(ARRAYSIZE,flagcirc)
%--------------------------------------------------------------------------
% A wrapper for making diagonal binary masking matrix for n-d tensor signal
% - the circulant matrix has the "wrap-around-effect" occuring on the 
%   first row (the previous version had this on the last row).
%--------------------------------------------------------------------------
% (02/12/2014)
%%
switch length(ARRAYSIZE)
    case 1
        B=tak_circmask_1d_newcirc(ARRAYSIZE);
    case 2
        B=tak_circmask_2d_newcirc(ARRAYSIZE);
    case 3
        B=tak_circmask_3d_newcirc(ARRAYSIZE);
    case 4
        B=tak_circmask_4d_newcirc(ARRAYSIZE);
    case 6
        B=tak_circmask_6d_newcirc(ARRAYSIZE);
    otherwise
        error('Unsupported dimension!!!')
end