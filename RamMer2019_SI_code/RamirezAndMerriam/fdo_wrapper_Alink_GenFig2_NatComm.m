function [Res] = fdo_wrapper_Alink_GenFig2_NatComm(sigma_tuning, granularity, noise_type, noise_level, paradigm, analyses,flag_figure_local)

% sigma_tuning  
% granularity 
% noise_type 
% noise_level 
% paradigm 
% analyses
%
% Orientation (in deg) for cond1 & cond2 are fixed within model_Alink_run_in_loop_xx.m
% cond1         orientation of putative grating (in degrees): condition 1
% cond2         orientation of putative grating (in degrees): condition 2

% ------------------------------ START ------------------------------------
a = 0.5; b = 0.5; % a & b values must be specified as input, but are not used here.
% This function could serve as basis:
[Res] = model_Alink_run_in_loop_xx(paradigm, analyses, a, b, sigma_tuning, granularity, noise_type,noise_level,flag_figure_local);

% whos Res


