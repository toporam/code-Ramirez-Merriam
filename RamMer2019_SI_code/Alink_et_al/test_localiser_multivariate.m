
% Simulation to show that defining voxels based on orthogonal contrast does not
% bias repetition effects in Alink et al paper

clear

% Number of expriments/subjects
Nh = 1; Ns = 1000;   % To produce mean repetition effects
% Nh = 1000; Ns = 20;   % To produce distribution of repetition effects

Nv = 1000; % initial number of voxels
Nt = 100;  % number of trials
SNR = 0.1;

B = [2 2 1 1]';  % Mean for F1, F2, S1, S2;
Nc = length(B);

% create some patterns across voxels
Bpat = kron(kron(B,ones(Nt,1)),ones(1,Nv));  % base pattern
pat  = detrend([kron([1:Nv],[1 1]'); kron([Nv:-1:1],[1 1]')]/Nv,0); % This implements different patterns for F and S (same regardless of repetition)
% pat  = detrend([kron([1:Nv],[1 0.5]'); kron([Nv:-1:1],[1 0.5]')]/Nv,0); % This implements suppressed patterns for F and S
%%pat  = detrend([[1:Nv]; [1:2:Nv (Nv-1):-2:1]; [Nv:-1:1]; [(Nv-1):-2:1 1:2:Nv]]/Nv,0); % This implements indepdent repetition-changes in patterns for F and S
%%pat  = detrend([[1:Nv]; [1:2:Nv (Nv-1):-2:1]; [Nv:-1:1]; [1:2:Nv (Nv-1):-2:1]]/Nv,0); % This implements repetition abolishing pattern difference for F and S
Bpat = Bpat + kron(pat,ones(Nt,1));

X = kron(eye(Nc),ones(Nt,1)); pX = pinv(X);

rng('default'); 
allv = []; locv = [];
for h=1:Nh
    ally = {}; locy = {};  
    for g=1:Ns
         
        % Generate data and noise
        y = Bpat + randn(Nt*Nc,Nv)/SNR;
        ally{g} = y;
        
        % Evaluate significance of localising contrast at each voxel
        c = [1 1 -1 -1];
        [T,p] = fit_glm(X,y,c);
        
        % Select just voxels below some threshold (p-value)
        ind = find(p<.05); Nsv = length(ind); bias(h,1) = Nsv/Nv;
        y = y(:,ind);
        locy{g} = y;
        
        fprintf('.');
    end
    fprintf('\n')
    
    [eff,tval] = repeffects(ally,0);
    allv(h,:) = struct2array(eff);
    [eff,tval] = repeffects(locy,0);
    locv(h,:) = struct2array(eff);
end

if Ns >= 100
%    repeffects(ally,1); % Will graph repetition effects for all voxels
   repeffects(locy,1); % Will graph repetition effects for localised (loc) voxels
end

names = fieldnames(eff);
if Nh >= 100
    figure,
    for c=1:size(allv,2)
        subplot(1,6,c), hist([allv(:,c) locv(:,c)]),title(names{c}) % blue is all, yellow is loc
    end
end
