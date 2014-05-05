function B=tak_circmask_1d(n)
% B=tak_circmask_1d(n)
%----------------------------------------------------------------------------------
% Create diagonal binary masking matrix B, which masks the "wrap-around" artifacts 
% from using the circulant difference matrix created from tak_diffmat_1d(n,1)
%----------------------------------------------------------------------------------
% B: (n x n) diagonal binary masking matrix
%----------------------------------------------------------------------------------
% 06/23/2013
%----------------------------------------------------------------------------------
%%
B=speye(n);
B(n,n)=0;