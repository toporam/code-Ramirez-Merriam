AlinkThis directory contains 4 Matlab scripts and 2 data files for the two fMRI experiments reported in the paper. 

The face_data.mat and grating_data.mat data files each contain 18 cells representing voxel by trial responses for 18 subjects from the main ROIs used in each experiment. 

The *.m scripts are simplified versions of the analyses presented in the paper. To generate the main results presented in that paper, please run the MasterScript.m file. Note you first need to set up the paths for the data files, as well as the remaining three functions (paradigm_setting.m, simulate_adaptation.m and repeffects.m).

Follow the comments in the script to know more about each variable and how to use them. Also, refer back to the paper for the theory and the detailed explanation of the models.

The functions test_orthog_contrasts.m, test_localiser_multivariate.m and fit_glm.m were added later to simulate various simple voxel-level models and to test for bias when selecting voxels on an orthogonal contrast, in response to a reviewer.

Code by: hunar.abdulrahman@mrc-cbu.cam.ac.uk and rik.henson@mrc-cbu.cam.ac.uk