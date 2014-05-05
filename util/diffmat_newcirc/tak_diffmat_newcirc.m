function C = tak_diffmat_newcirc(ARRAYSIZE,flagcirc)
% C = tak_diffmat_newcirc(ARRAYSIZE,flagcirc)
% (02/12/2014)
%--------------------------------------------------------------------------
% A wrapper for making difference matrix for n-d tensor signal
% - the circulant matrix has the "wrap-around-effect" occuring on the 
%   first row (the previous version had this on the last row).
%--------------------------------------------------------------------------
%%
switch length(ARRAYSIZE)
    case 1
        C=tak_diffmat_1d_newcirc(ARRAYSIZE,flagcirc);
    case 2
        C=tak_diffmat_2d_newcirc(ARRAYSIZE,flagcirc);
    case 3
        C=tak_diffmat_3d_newcirc(ARRAYSIZE,flagcirc);
    case 4
        C=tak_diffmat_4d_newcirc(ARRAYSIZE,flagcirc);
    case 6
        C=tak_diffmat_6d_newcirc(ARRAYSIZE,flagcirc);
    otherwise
        error('Unsupported dimension!!!')
end