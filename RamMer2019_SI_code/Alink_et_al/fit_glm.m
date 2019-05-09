function [T,p] = fit_glm(X,y,c);
% Code for any General Linear Model (eg T-test)

Bhat  = pinv(X)*y;
Y = X*Bhat;
r = y - Y;
df = size(y,1) - rank(X);
s = r'*r / df; s = diag(s)';

T = c*Bhat ./ sqrt(s*(c*pinv(X'*X)*c'));
p = 2 * tcdf(-abs(T), df); % two-tailed
 
return
