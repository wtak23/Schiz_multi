function [C,CX,CY]=tak_diffmat_2d(ARRAYSIZE,flagcirc)
% [C,CX,CY]=tak_diffmat_2d(ARRAYSIZE,flagcirc
%----------------------------------------------------------------------------------
% Create 2-d first order difference matrix
%----------------------------------------------------------------------------------
% INPUT
%   ARRAYSIZE = [X Y Z] -> dimension size of the array
%   flagcirc: '0' -> make non-circulant difference matrix [default]
%             '1' -> make circulant difference matrix 
%                    (creates wrap-around terms, so use with caution)
%----------------------------------------------------------------------------------
% OUTPUT
%  C: C = [CX; CY]
%   where CX,CY: difference operator on each of the 2 dimensions   
%----------------------------------------------------------------------------------
% Note: if flagcirc==1: 
%   C: (2N x N) matrix, where N = (X*Y) 
%   CX,CY: (N x N) matrix
%----------------------------------------------------------------------------------
% 06/19/2013
%----------------------------------------------------------------------------------
%%
% default: non-circulant difference matrix
if nargin==1 
    flagcirc=0;
end

X=ARRAYSIZE(1);
Y=ARRAYSIZE(2);

%==================================================================================
% Create 1-D difference matrix for each dimension
%==================================================================================
DX=diffmat_1d(X,flagcirc);
DY=diffmat_1d(Y,flagcirc);

%==================================================================================
% create first order difference operator for each array dimension
%==================================================================================
CX=kron(speye(Y),DX);
CY=kron(DY,speye(X));

%==================================================================================
% create final difference matrix
%==================================================================================
C=[CX;CY];

end
%==================================================================================
% Private functions:
% - create 1D difference matrix
%   option=0 
%    -> D = (n-1 x n) matrix with no circulant structure
%   option=1 
%    -> D = (n x n) matrix with circulant structure...
%    -> the circulant structure creates a "wrap-around term"
%       (for an N-D vector x, the last entry of the product D*x will be x1-xN...
%        which may not be sensible)
%==================================================================================
function D=diffmat_1d(n,flagcirc)
if nargin==1 
    flagcirc=0;
end

% (n-1 x n) incidence/difference matrix
D = sparse(1:n-1, 2:n, 1, n-1, n)-sparse(1:n-1, 1:n-1, 1, n-1, n);

if flagcirc % pad a row at the bottom that adds the (x1-xN) effect
    D = [D; 1 zeros(1,n-2) -1];
end
end