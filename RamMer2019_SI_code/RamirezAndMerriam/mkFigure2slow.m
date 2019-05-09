
% --------------------------------------------------------------------------
% Script reproduces smooth-looking surface shown in Figure 2b of Ramirez
% and Meriam (2019). Script runs mkFigure1fast.m 25 times and saves
% results, retreives saved results, computes average matrix, and create
% surface plot
% --------------------------------------------------------------------------

% Instructions: 
% 1. Make sure all paths set in Matlab
% 2. Specify path2save, that is, the location of the directory were to save
% the results of each simulation

nIterations = 25; % self explanatory

path2save = '/Users/ramirezfm/Desktop/RamMer2019_SI_code/'

scurr = rng('default');
% tic
for ind = 1:nIterations
    
    mkFigure2fast, clear s h
    
    % cumEuc = (1:10).*ones(10,1);
    name2save = ['iteration' num2str(ind) '.mat'];
    save([path2save, name2save])
    
    disp([name2save ' ... ready, results saved'])
    
end
% toc

for ind = 1:nIterations
        
    name2save = ['iteration' num2str(ind) '.mat'];    
    load([path2save, name2save])
    
    cumcumEuc(:,:,ind) = cumEuc;

end


%**************************************************************************
% PLOT THE NON-FLAT SURFACE
%**************************************************************************
% h = figure('position',[1 1 978 825]);
h = figure;
s = surf(squeeze(mean(cumcumEuc,3))./8,'FaceColor','interp','FaceLighting','gouraud'); 
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

%**************************************************************************
% PLOT THE FLAT SURFACE
%**************************************************************************
% h = figure('position',[1 1 978 825]);
h2 = figure;
s2 = surf(ones(10,10).*1.125./8,'FaceColor','interp','FaceLighting','gouraud');
colormap cool
xlabel('granularity [# granules per voxel]')
ylabel('sigma tuning [deg.]')
zlabel('signal strength (arbitrary unit)')
az = 130 ; el = 19; view([az,el])
% axis square tight
ylim([1 10])
xlim([1 10])
axis square
s2.LineStyle = ':';
set(gca,'yTickLabels',{10:10:100})
set(gca,'xTickLabels',{pow2(0:9)})
set(gca,'zlim',[0 0.7])
