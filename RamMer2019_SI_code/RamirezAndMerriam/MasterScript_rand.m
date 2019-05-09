
clear
% NOTE: function adds zero-mean Gaussina noiseto simulated patterns
% Ensure functions below on your path 
% cd C:\Users\Hunar\Desktop\paper_figures\to_send\osf_script

%% setting up the paradigm and parameter values
v=200;                                              %number of voxels for simulation
X=pi;                                               %stimulus dimension
cond1=1/4*X;                                        %first stimulus type
cond2=3/4*X;                                        %second stimulus type
model_type=2;                                       %choose model type among 12 neural models
sub_num=18;                                         %number of subjects, fix to 18 to avoid errors

noise=0.1;    
faceData='face_data.mat';
gratingData='grating_data.mat';

%% choose the analyses type
paradigm='grating';                 % options: 'grating' or 'face'
analyses='simulation';                 % options: 'fmri' or 'simulation'

% Note that results for "simulation" option above might differ slightly
% from Supplementary Figures in paper owing to different random seeds

[j, ind, reset_after, winning_params]=paradigm_setting(paradigm,cond1,cond2);


%explore the free parameters
% sigma=0.4; a=0.8; b=0.4;
% or try the optimal ones that fit the data (only in local scaling model)
sigma=winning_params.sigma;                 % controls the initial tuning width
a=winning_params.a;                         % controls the amount of the adaptation
b=winning_params.b;                         % controls the spread of the adaptation

%% re-arranging the trial sequences to group them into intial and reated presentations of cond1 and cond2
for sub=1:sub_num;
    fprintf('.')
    if(strcmp(paradigm,'face')==1);
        if(strcmp(analyses,'simulation')==1);
            %% the core fuction that generates the initial and repeated patterns - outputs: [presentation x voxel] matrix
            [out]=simulate_adaptation(v, X, j, cond1, cond2, a, b, sigma, model_type, reset_after, paradigm);
            pattern=(out.pattern' + rand(v,length(j))*noise)';
        elseif(strcmp(analyses,'fmri')==1);
            load(faceData)
            pattern=pat{sub};
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

    elseif(strcmp(paradigm,'grating')==1);
        if(strcmp(analyses,'simulation')==1);
            %% the core fuction that generates the initial and repeated patterns - outputs: [presentation x voxel] matrix
            [out]=simulate_adaptation(v, X, j, cond1, cond2, a, b, sigma, model_type, reset_after, paradigm);
            pattern=(out.pattern' + rand(v,length(j))*noise)';
        elseif(strcmp(analyses,'fmri')==1);
            load(gratingData)
            pattern=pat{sub};
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

%% analysing the repetition effects on y which is a cell array of subjects, each entry with trial x voxel matrix
[B, t_vals]=repeffects(y)
