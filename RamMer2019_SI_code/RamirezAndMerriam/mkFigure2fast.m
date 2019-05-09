% GOAL: provide code to replicate Figure 2 of Ramírez & Merriam (2019) (at
% Alink's request). Function is evidently based on the code published by
% Alink et al (2018). Fernando Ramírez, 11 March 2019

%**************************************************************************
% Instructions:
%**************************************************************************
% 1. Make sure the directory including all required functions (see
% readme.txt) is in your matlab path. addpath
% /Users/ramirezfm/Desktop/RamMer2019_SI_code/Alink_et_al addpath
% /Users/ramirezfm/Desktop/RamMer2019_SI_code/RamirezAndMerriam

% 2. Set flags:
flag_getPatterns = 1; % obtain response patterns for each model parameter combination {G, sigma_tuning}
flag_mkFig = 1; % Make surface plot reproducing Fig. 2b in our letter.
flag_figure_local = 0; % Used for debugging. Keep it this way - i.e. set to  0
%**************************************************************************

% rng(scurr) scurr = rng; % get seed & save it in case it were needed
% rng('default')
%**************************************************************************
% Run Alink et al's model for multiple sigma_tuning & granularity-levels
%**************************************************************************
paradigm = 'grating';                   % Don't change
analyses = 'simulation';                % Don't change
noise_type = 'randn';                   % 'rand' or 'randn'
noise_level = 0;                        % Not interested here on noise effects, set to 0

% *************************************************************************
% Note: Orinetations of the two visual gratings in this simulation are 45 &
% 90 deg
% *************************************************************************
% cond1 = 45; % angle in deg. of first simulated stimulus grating in
% degrees cond2 = 90; % angle of second simulated stimulus grating in
% degrees Parameters are fixed @ model_Alink_run_in_loop_xx.m
% *************************************************************************

v_sigmaTuning = (deg2rad(10:10:100)); % rad2deg(pi/1.5) = 120 deg
v_granularityLevel = pow2(0:9); % i.e., [1 2 4 8 16 32 64 128 256 512]

if flag_getPatterns
    tic
    indS = 0;
    for local_sigma = v_sigmaTuning
        indS = indS+1;
        
        indG = 0;
        for local_G = v_granularityLevel
            indG = indG+1;
            cumPatterns{indS, indG} = fdo_wrapper_Alink_GenFig2_NatComm(local_sigma, local_G, noise_type, noise_level, paradigm, analyses,flag_figure_local);% #ok<SAGROW>
        end
        
    end
    toc
end

if flag_mkFig
    % Make figure showing pairwise Euclidean distances of the generated
    % patterns
    
    indS = 0;
    for local_sigma = v_sigmaTuning
        indS = indS+1;
        
        indG = 0;
        for local_G = v_granularityLevel
            indG = indG+1;
            auxPatterns = cumPatterns{indS, indG};
            cumEuc(indS, indG) = pdist(auxPatterns'); %#ok<SAGROW>
            
            clear auxPatterns
        end
    end
    
    %     figure,surf(cumEuc./10), colormap cool xlabel('granularity [2^x]')
    %     ylabel('sigma tuning [rad]') zlabel('signal strength [arbitrary
    %     unit]') az = 130 ; el = 19; view([az,el]) axis square tight
    
    %**************************************************************************
    % PLOT THE NON-FLAT SURFACE
    %**************************************************************************
    % h = figure('position',[1 1 978 825]);
    h = figure;
    s = surf(cumEuc./8,'FaceColor','interp','FaceLighting','gouraud');
    colormap cool
    xlabel('granularity [# granules per voxel]')
    ylabel('sigma tuning [deg.]')
    zlabel('signal strength (arbitrary unit)')
    az = 130 ; el = 19; view([az,el])
    % axis square tight
    ylim([1 10])
    xlim([1 10])
    axis square
    s.LineStyle = ':';
    set(gca,'yTickLabels',{10:10:100})
    set(gca,'xTickLabels',{pow2(0:9)})
    set(gca,'zlim',[0 0.7])
    
    toc
end