function [j, ind, reset_after, wining_params]=paradigm_setting(paradigm,cond1,cond2)
% this function sets up the paradigm configuration for the simulation to
% match that of the emperical data and returns: j, which sets up paradigm
% trial orders in "j", and "ind" variables which returns the trial type and presentation indecies
%
% Version 1.0   8-June-2017         Hunar.Abdulraham@mrc-cbu.cam.ac.uk

%% paradigm
if(strcmp(paradigm,'face')==1);
    
    reset_after=2; % resets the adaptation factor, c, after each repetition// unlike the grating paradigm the initial presentation cond1 for each condition (face) was unique (novel) so there should be no adaptation upon the first expore of each face
    j=[ cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        cond1 cond1 ...
        cond2 cond2 ...
        ];
    
    %label the conditions and presentations
    condition=repmat([1 1 0 0 ],1,8);
    presentation=repmat([1 2 ],1,16);
    cond1_p1=find(condition==1 & presentation==1);
    cond1_p2=find(condition==1 & presentation==2);
    cond2_p1=find(condition==0 & presentation==1);
    cond2_p2=find(condition==0 & presentation==2);
    
    % return indices
    ind.cond1_p1=cond1_p1;
    ind.cond1_p2=cond1_p2;
    ind.cond2_p1=cond2_p1;
    ind.cond2_p2=cond2_p2;
    
    % a combintation of optimal parameters that will fit the face data
    % (found using a grid search analyses for a wide range of parameters)
    wining_params.sigma=0.2;
    wining_params.a=0.7;
    wining_params.b=0.2;
    
elseif(strcmp(paradigm,'grating')==1)
    
    reset_after=6; % resets the adatpation factor (c) after each run// because there was a long break between the runs
    j=[ cond1 cond2 cond1 cond2 cond1 cond2 ...
        cond2 cond1 cond2 cond1 cond2 cond1 ...
        cond1 cond2 cond1 cond2 cond1 cond2 ...
        cond2 cond1 cond2 cond1 cond2 cond1 ...
        cond1 cond2 cond1 cond2 cond1 cond2 ...
        cond2 cond1 cond2 cond1 cond2 cond1 ...
        cond1 cond2 cond1 cond2 cond1 cond2 ...
        cond2 cond1 cond2 cond1 cond2 cond1 ...
        ];
    
    %labeling the conditions and presentations
    condition=repmat([1 0 1 0 1 0 0 1 0 1 0 1],1,4);
    presentation=repmat([1 1 2 2 3 3],1,8);
    cond1_p1=find(condition==1 & presentation==1);
    cond1_p2=find(condition==1 & presentation==2);
    cond1_p3=find(condition==1 & presentation==3);
    cond2_p1=find(condition==0 & presentation==1);
    cond2_p2=find(condition==0 & presentation==2);
    cond2_p3=find(condition==0 & presentation==3);
    
    %return indecies
    ind.cond1_p1=cond1_p1;
    ind.cond1_p2=cond1_p2;
    ind.cond1_p3=cond1_p3;
    ind.cond2_p1=cond2_p1;
    ind.cond2_p2=cond2_p2;
    ind.cond2_p3=cond2_p3;
    
    % a combintation of optimal parameters that will fit the grating data
    % (found using a grid search analyses for a wide range of parameters)
    wining_params.sigma=0.4;
    wining_params.a=0.8;
    wining_params.b=0.4;
    
else
    error('Unknown Paradigm! Please set paradigm to either "face" or "grating"')
end
