function C = tak_diffmat(ARRAYSIZE,flagcirc)
% C = tak_diffmat(ARRAYSIZE,flagcirc)
%----------------------------------------------------------------------------------
% A wrapper for making difference matrix for n-d tensor signal
%----------------------------------------------------------------------------------
%%
switch length(ARRAYSIZE)
    case 1
        C=tak_diffmat_1d(ARRAYSIZE,flagcirc);
    case 2
        C=tak_diffmat_2d(ARRAYSIZE,flagcirc);
    case 3
        C=tak_diffmat_3d(ARRAYSIZE,flagcirc);
    case 4
        C=tak_diffmat_4d(ARRAYSIZE,flagcirc);
    case 6
        C=tak_diffmat_6d(ARRAYSIZE,flagcirc);
    otherwise
        error('Unsupported dimension!!!')
end