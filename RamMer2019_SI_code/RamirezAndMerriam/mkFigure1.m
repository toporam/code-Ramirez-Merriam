% Instructions for the replication of the results reported in Figure 1 of
% Ramírez & Merriam (2019)

% 1) Make sure to include all listed functions in your matlab path

% 2) The version of Alink et al.s' MasterScript.m included here uses the
% default parameters, exept for: Lines 15-16, where the parameters
% "paradigm" and "anayses" are specified. These parameters were set to:
% paradigm='grating';
% analyses='simulation';

rng('default'); % set random number generator to the default state

% ***********************************************************************
display('Replicating Figure 1 ...')
display('Figure 1 (top row):')

% Run Alink et al's MasterScript.m with default parameters to replicate the
% barplots reported in the top row of Ramírez and Merriam (2019)
MasterScript_rand

% ***********************************************************************
% To repicate the barlots on the botom row of our Figure 1 it is necessary
% to change line 63 of Alink's MasterScript.m from:
%
%           pattern=(out.pattern' + rand(v,length(j))*noise)';
%
%           to
%
%           pattern=(out.pattern' + randn(v,length(j))*noise)';
%
% Function MasterScript_randn.m includes this change.

rng('default'); % set random number generator to the default state

display('Figure 1 (bottom row):')

MasterScript_randn

display('done')
            


