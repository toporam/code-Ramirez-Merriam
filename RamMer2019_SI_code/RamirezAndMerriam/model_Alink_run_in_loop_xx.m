function [output] = model_Alink_run_in_loop_xx(paradigm, analyses, a_loop, b_loop, sigma_loop, granularity_loop, noise_type, noise_level,flag_figure)
% Adapted Master-function from Alink et al 2018 to run in loops and
% retreive response patterns associated with the two specified stimuli
% (oriented gratings)

%% setting up the paradigm and parameter values
v= 100; % 200;                                        % number of voxels for simulation
X = pi;                                               % stimulus dimension
cond1 = 1/4*X; % 45 deg % 1/4*X;                      % first stimulus type
cond2 = 2/4*X; % 90 deg % 3/4*X;                      % second stimulus type
model_type = 2; % 5 is local sharpening (NaNs)        % choose model type among 12 neural models
sub_num = 1; % 18;                                    % number of subjects, fiexed to 1

% faceData='face_data.mat';
% gratingData='grating_data.mat';

[j, ind, reset_after, winning_params]=paradigm_setting(paradigm,cond1,cond2);
% winning_params will not be used, but j, ind, reset_after, are needed to
% sort and concatenate simulated brain patterns

%% re-arranging the trial sequences to group them into intial and reated presentations of cond1 and cond2
for sub=1:sub_num
    fprintf('.')
    if(strcmp(paradigm,'face')==1)
        if(strcmp(analyses,'simulation')==1)
            %% the core fuction that generates the initial and repeated patterns - outputs: [presentation x voxel] matrix
            [out]=simulate_adaptation_withG(v, X, j, cond1, cond2, a_loop, b_loop, sigma_loop, granularity_loop, model_type, reset_after, paradigm);
%             pattern=(out.pattern' + rand(v,length(j))*noise)';
            if noise_type == 'rand'
                pattern=(out.pattern' + rand(v,length(j))*noise_level)';
            elseif noise_type == 'randn'
                pattern=(out.pattern' + randn(v,length(j))*noise_level)';
            else
                error('noise_type unknown')
            end
            
        elseif(strcmp(analyses,'fmri')==1)
            % load(faceData)
            % pattern=pat{sub};
            error('Function not meant to be used to retreive the empirical data. Set analyses = ''simulation'' in wrapper function')
        else
            error('Unkown Operation, please choose either: "simulation" or "fmri"');
        end
        v=size(pattern,2); % voxels number
        %grouping the trials according to conditions and presentations
        %(trials ordered according to the paradigm -see j parameter)
        cond1_p{1}=pattern(1:4:end,1:v);
        cond2_p{1}=pattern(3:4:end,1:v);
        cond1_p{2}=pattern(2:4:end,1:v);
        cond2_p{2}=pattern(4:4:end,1:v);
        
        y{sub}=[cond1_p{1}; cond1_p{2}; cond2_p{1}; cond2_p{2}];

    elseif(strcmp(paradigm,'grating')==1)
        if(strcmp(analyses,'simulation')==1)
            %% the core fuction that generates the initial and repeated patterns - outputs: [presentation x voxel] matrix
            [out]=simulate_adaptation_withG(v, X, j, cond1, cond2, a_loop, b_loop, sigma_loop, granularity_loop, model_type, reset_after, paradigm);
%             [out]=simulate_adaptation_catchNaNs(v, X, j, cond1, cond2, a_loop, b_loop, sigma_loop, model_type, reset_after, paradigm);
            
            if strcmp(noise_type,'rand')
                pattern=(out.pattern' + rand(v,length(j))*noise_level)';
            elseif strcmp(noise_type,'randn')
                pattern=(out.pattern' + randn(v,length(j))*noise_level)';
            else
                error('noise_type unknown')
            end
            
        elseif(strcmp(analyses,'fmri')==1)
            % load(gratingData)
            % pattern=pat{sub};
            error('Function not meant to be used to retreive the empirical data. Set analyses = ''simulation'' in wrapper function')
        else
            error('Unkown Operation, please choose either: "simulation" or "fmri"');
        end
        v=size(pattern,2); % voxel number
        %grouping the trials according to conditions and presentations
        %(trials ordered according to the paradigm -see j parameter)
        cond1_p{1}=pattern(ind.cond1_p1,1:v);
        cond2_p{1}=pattern(ind.cond2_p1,1:v);
        cond1_p{2}=pattern(ind.cond1_p3,1:v);
        cond2_p{2}=pattern(ind.cond2_p3,1:v);
        
        y{sub}=[cond1_p{1}; cond1_p{2}; cond2_p{1}; cond2_p{2}];
    end
end

% get mean respose across voxels before and after adaptation
res_patterns = y{sub};

%
v=size(res_patterns,2); % voxels
n=size(res_patterns,1); % trials
if rem(n,4)~=0 error('Assumes 4 conditions with equal trials'); end
cond1_p{1}=res_patterns([1:(n/4)], 1:v);
cond2_p{1}=res_patterns([1:(n/4)]+n/2, 1:v);
cond1_p{2}=res_patterns([1:(n/4)]+n/4, 1:v);
cond2_p{2}=res_patterns([1:(n/4)]+3*n/4, 1:v);
cond1r1=mean(cond1_p{1});
cond2r1=mean(cond2_p{1});
cond1r2=mean(cond1_p{2});
cond2r2=mean(cond2_p{2});

title_local = ['sigma\_tuning=' num2str(sigma_loop) ' | granularity=' num2str(granularity_loop)];
% figure,bar([cond1r1, cond2r1, cond1r2, cond2r2])
if flag_figure
    figure,bar([mean(cond1r1), mean(cond2r1), mean(cond1r2), mean(cond2r2)])
    title(title_local)
end

% Need Euclidean distance of response patterns for cond1 and cond2 (defined
% across voxels) without adaptation
output(:,1) = pattern(1,:); % responses across voxels for condition 1 without adaptation (1 means first presentatio of first set >1-2,1-2,1-2, 2-1,2-1,2-1 ... nblocks = 48)
output(:,2) = pattern(7,:); % responses across voxels for condition 2 without adaptation (7 means first presentation after first set 12,12,12, >21,21,21 ... nblocks = 48)

% whos output



%% analysing the repetition effects on y which is a cell array of subjects, each entry with trial x voxel matrix
% [B, t_vals]=repeffects(y,0) % do plotting
% [B, t_vals]=repeffects(y,0) % skip plotting
