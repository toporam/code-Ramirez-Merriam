
% Simulation to show that defining voxels based on one contrast does not
% bias univariate stats for a second orthogonal contrast
% (see generalised code for multivariate pattern test)

Nv = 1000;  % initial number of voxels
Nt = 100;   % number of trials
SNR = 0.1;  % signal-to-noise ratio

% Mean for 4 conditions (eg F1, F2, S1, S2 in Alink et al)
B = [2 2 1 1]';  % F > S, 1=2 (ie no repetition effect)
%B = [2 1 1 0]';  % F > S and 1>2 (repetition effect)

Nc = length(B);
Bpat = kron(kron(B,ones(Nt,1)),ones(1,Nv));  % base pattern across trials+voxels
% (see generalised code for multivariate pattern test)
X = kron(eye(Nc),ones(Nt,1));  % Design matrix for GLM below

bias = [];
for h=1:1000

    % Generate data and noise
    y = Bpat + randn(Nt*Nc,Nv)/SNR;
    
    % Evaluate significance of localising contrast at each voxel
    c = [1 1 -1 -1];   
    [T,p] = fit_glm(X,y,c);
    
    % Select just voxels below some threshold (p-value)
    ind = find(p<.05); Nsv = length(ind); bias(h,1) = Nsv/Nv;
    y = y(:,ind);

    % y = mean(y,2); % average across voxels if want ROI stats (makes no difference)   

    % Evaluate significance of test contrast on each voxel
    c = [1 -1 1 -1];  % orthogonal, so does not inflate false positive rate
%    c = [1 -1 0 0];  % orthogonal, so does not inflate false positive rate
%    c = [0 0 1 -1];  % orthogonal,so does not inflate false positive rate
%    c = [1 0 -1 0];  % correlated, so does inflate false positive rate

    [T,p] = fit_glm(X,y,c);
   
    ind = find(p<.05); bias(h,2) = length(ind)/Nsv;
    
    fprintf('.');
end
fprintf('\n')

mean(bias)

figure,
subplot(1,2,1),hist(bias(:,1)),title('Localising Contrast'), 
subplot(1,2,2),hist(bias(:,2)),title('Main Contrast')




