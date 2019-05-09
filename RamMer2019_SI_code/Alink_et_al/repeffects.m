function [B,t] = repeffects(y,pflag)

if nargin<2
    pflag=1;
end

%% Assumes y is a cell array of subjects, each entry with trial x voxel matrix

t=[];B=[];

for sub=1:length(y);
    
    pattern = y{sub};
    
    v=size(pattern,2); % voxels
    n=size(pattern,1); % trials
    if rem(n,4)~=0 error('Assumes 4 conditions with equal trials'); end
    
    cond1_p{1}=pattern([1:(n/4)], 1:v);
    cond2_p{1}=pattern([1:(n/4)]+n/2, 1:v);
    cond1_p{2}=pattern([1:(n/4)]+n/4, 1:v);
    cond2_p{2}=pattern([1:(n/4)]+3*n/4, 1:v);
    
    cond1r1=mean(cond1_p{1});
    cond2r1=mean(cond2_p{1});
    cond1r2=mean(cond1_p{2});
    cond2r2=mean(cond2_p{2});
    
    %% analysing the 6 adaptation criteria in the voxel pattern
    
    %% MAM average repetition effect
    avgAmp1r1(sub,:)=mean(cond1r1);
    avgAmp2r1(sub,:)=mean(cond2r1);
    avgAmp1r2(sub,:)=mean(cond1r2);
    avgAmp2r2(sub,:)=mean(cond2r2);
    
    avgR1=(avgAmp1r1+avgAmp2r1)/2;
    avgR2=(avgAmp1r2+avgAmp2r2)/2;
    
    %% AMA adaptation by amplitude
    [sAmp1r ind1]=sort(mean([cond1_p{1}' cond1_p{2}' ],2));
    [sAmp2r ind2]=sort(mean([cond2_p{1}' cond2_p{2}' ],2));
    sAmp1r1=(cond1r1(ind1));
    sAmp2r1=(cond2r1(ind2));
    sAmp1r2=(cond1r2(ind1));
    sAmp2r2=(cond2r2(ind2));
    
    sAmp=((sAmp1r1-sAmp1r2) + (sAmp2r1-sAmp2r2))/2;  % +ve slope indicate voxels higher in activity suppresses most
    
    %%% this will give the same result as above
    % [sAmp1r ind]=sort(mean([cond1_p{1}' cond1_p{2}' cond2_p{1}' cond2_p{2}'],2));
    % sAmp1r1=(cond1r1(ind));
    % sAmp2r1=(cond2r1(ind));
    % sAmp1r2=(cond1r2(ind));
    % sAmp2r2=(cond2r2(ind));
    % sAmp=((sAmp1r1-sAmp1r2) + (sAmp2r1-sAmp2r2))/2;  % +ve slope indicate voxels higher in activity suppresses most
    
    %% WC with class correlations
    wtc1(sub,:)=mean(mean((corr(cond1_p{1}','type','Pearson')+corr(cond2_p{1}','type','Pearson'))/2));
    wtc2(sub,:)=mean(mean((corr(cond1_p{2}','type','Pearson')+corr(cond2_p{2}','type','Pearson'))/2));
    
    %% BC between class correlations
    btc1(sub,:)=mean(mean(corr(cond1_p{1}',cond2_p{1}','type','Pearson')));
    btc2(sub,:)=mean(mean(corr(cond1_p{2}',cond2_p{2}','type','Pearson')));
    
    %% CP classification performance
    svm_init(sub,:)= wtc1(sub,:)- btc1(sub,:);
    svm_rep(sub,:)=wtc2(sub,:)- btc2(sub,:);
    
    %% AMS adaptation by selectivity
    [H,P,CI,STATS]=ttest2([cond1_p{1}; cond1_p{2}],[cond2_p{1}; cond2_p{2}]);
    tval1=STATS.tstat;
    [H,P,CI,STATS]=ttest2([cond2_p{1}; cond2_p{2}],[cond1_p{1}; cond1_p{2}]);
    tval2=STATS.tstat;
    
    [ignore tval_sorted_ind1]=sort(abs(tval1));
    c1_init=mean(cond1_p{1},1);
    c1_rep=mean(cond1_p{2},1);
    c1_sinit=c1_init(tval_sorted_ind1);
    c1_srep=c1_rep(tval_sorted_ind1);
    [ignore tval_sorted_ind2]=sort(abs(tval2));
    c2_init=mean(cond2_p{1},1);
    c2_rep=mean(cond2_p{2},1);
    c2_sinit=c2_init(tval_sorted_ind2);
    c2_srep=c2_rep(tval_sorted_ind2);
    
    abs_init_trend=(c1_sinit+c2_sinit)/2;
    abs_rep_trend=(c1_srep+c2_srep)/2;
    abs_adaptation_trend=abs_init_trend-abs_rep_trend;
    
    %% binning the AMA and AMS trends
    nBins=6;
    AA=sAmp;
    AS=abs_adaptation_trend;
    
    AS1=abs_init_trend;
    AS2=abs_rep_trend;
    
    percInds=(round(([1:numel(AA)]*(nBins-1))/numel(AA))/(nBins-1))*(nBins-1)+1;
    for i=1:nBins;
        sc_trend(sub,i)=mean(AA(find(percInds==i)));
        abs_ad_trend(sub,i)=mean(AS(find(percInds==i)));
    end
    fprintf('.');
end
fprintf('\n');

%% stats and figures
AM=[avgR1 avgR2 ];
CP=[svm_init svm_rep ];
WC=[wtc1 wtc2 ];
BC=[btc1 btc2 ];
AMA=[sc_trend];
AMS=[abs_ad_trend];

L = 2;
X = [[1:L]' ones(L,1)]; pX = pinv(X);
for sub=1:length(y);
    Beta = pX*squeeze(AM(sub,:)');
    AM_slope(sub) = Beta(1);
    Beta = pX*squeeze(CP(sub,:)');
    CP_slope(sub) = Beta(1);
    Beta = pX*squeeze(WC(sub,:)');
    WC_slope(sub) = Beta(1);
    Beta = pX*squeeze(BC(sub,:)');
    BC_slope(sub) = Beta(1);
end

[H,P,ci,stats] = ttest(AM_slope');
my = mean(AM_slope');

L = nBins;
X = [[1:L]' ones(L,1)]; pX = pinv(X);
for sub=1:length(y);
    Beta = pX*squeeze(AMS(sub,:)');
    AMS_slope(sub) = Beta(1);
    Beta = pX*squeeze(AMA(sub,:)');
    AMA_slope(sub) = Beta(1);
end

B.AM = mean(AM_slope);
B.WC = mean(WC_slope);
B.BC = mean(BC_slope);
B.CP = mean(CP_slope);
B.AMS = mean(AMS_slope);
B.AMA = mean(AMA_slope);

[h p{1} sci{1} stats]=ttest(AM_slope); t.AM = stats.tstat;
[h p{2} sci{2} stats]=ttest(WC_slope); t.WC = stats.tstat;
[h p{3} sci{3} stats]=ttest(BC_slope); t.BC = stats.tstat;
[h p{4} sci{4} stats]=ttest(CP_slope); t.CP = stats.tstat;
[h p{5} sci{5} stats]=ttest(AMS_slope); t.AMS = stats.tstat;
[h p{6} sci{6} stats]=ttest(AMA_slope); t.AMA = stats.tstat;


%% figures

if pflag
    
    MetricNames = {'MAM', 'WC', 'BC', 'CP','AMS','AMA'};
    
    clear ci;
    [H,P,ci{1}] = ttest(AM);
    [H,P,ci{2}] = ttest(WC);
    [H,P,ci{3}] = ttest(BC);
    [H,P,ci{4}] = ttest(CP);
    [H,P,ci{5}] = ttest(AMS);
    [H,P,ci{6}] = ttest(AMA);
    
    Metric{1}=mean(AM);
    Metric{2}=mean(WC);
    Metric{3}=mean(BC);
    Metric{4}=mean(CP);
    Metric{5}=mean(AMS);
    Metric{6}=mean(AMA);
    
    
    mslop{1}=B.AM;
    mslop{2}=B.WC;
    mslop{3}=B.BC;
    mslop{4}=B.CP;
    mslop{5}=B.AMS;
    mslop{6}=B.AMA;
    
    darkgray=[0.5 0.5 0.5];
    lightgray=[0.75 0.75 0.75];
    str={'init ', 'rep'};
    
    figure; clf;
    for j=1:6;
        
        L=length(Metric{j});
        subplot(1,6,j);
        
        min_ylim=min(min(ci{j})); max_ylim=max(max(ci{j}));
        if(j>4)
            bar(Metric{j},'k');
        else
            bar(Metric{j}, 'FaceColor', darkgray);
            hold on; bar(2,Metric{j}(2),'FaceColor', lightgray);
            set(gca, 'XTickLabel',str, 'XTick',1:numel(str));
        end
        title(sprintf('%s: p=%0.3f',MetricNames{j}, p{j}));  xlim([0,L+1]); ylim([min_ylim, max_ylim]);
        
        %positioning the slop appropriately on the y-axis
        if(Metric{j}(1)>Metric{j}(end));
            iy=max_ylim;
        else
            iy=Metric{j}(1);
        end
        my = mslop{j};
        line([1 L],[0 (L-1)*sci{j}(1)]+iy,'LineStyle','--','Color','k','LineWidth',1)
        line([1 L],[0 (L-1)*my]+iy,'LineWidth',2,'Color','k')
        line([1 L],[0 (L-1)*sci{j}(2)]+iy,'LineStyle','--','Color','k','LineWidth',1)
        for b=1:L
            line([b b],[ci{j}(1,b) ci{j}(2,b)],'Color','k')
        end
        
    end
end

%% simpler figure

%     subplot(1,6,1);
%     mAM=mean(AM);
%     bar(mAM, 'FaceColor', darkgray); title(sprintf('MAM: T=%4.3f, p=%0.3f',t.AM,pAM)); ylim([min(mean(AM))-mean(std(AM)),max(mean(AM))+mean(std(AM))])
%     hold on; bar(2,mAM(2),'FaceColor', lightgray);
%     set(gca, 'XTickLabel',str, 'XTick',1:numel(str))
%     subplot(1,6,2);
%     mWC=mean(WC);
%     bar(mWC,'FaceColor', darkgray);  title(sprintf('WC: T=%4.3f, p=%0.3f',t.CP,pWC)); ylim([min(mean(WC))-mean(std(WC)),max(mean(WC))+mean(std(WC))])
%     hold on; bar(2,mWC(2),'FaceColor', lightgray);
%     set(gca, 'XTickLabel',str, 'XTick',1:numel(str))
%     subplot(1,6,3);
%     mBC=mean(BC);
%     bar(mBC,'FaceColor',darkgray ); title(sprintf('BC: T=%4.3f, p=%0.3f',t.WC,pBC)); ylim([min(mean(BC))-mean(std(BC)),max(mean(BC))+mean(std(BC))])
%     hold on; bar(2,mBC(2),'FaceColor', lightgray);
%     set(gca, 'XTickLabel',str, 'XTick',1:numel(str))
%     subplot(1,6,4);
%     mCP=mean(CP);
%     bar(mCP,'FaceColor',darkgray ); title(sprintf('CP: T=%4.3f, p=%0.3f',t.BC,pCP)); ylim([min(mean(CP))-mean(std(CP)),max(mean(CP))+mean(std(CP))])
%     hold on; bar(2,mCP(2),'FaceColor', lightgray);
%     set(gca, 'XTickLabel',str, 'XTick',1:numel(str))
%     subplot(1,6,5);
%     bar(mean(AMS),'k'); title(sprintf('AMS: T=%4.3f, p=%0.3f',t.AMS,pAMS)); ylim([min(mean(AMS))-mean(std(AMS)),max(mean(AMS))+mean(std(AMS))])
%     subplot(1,6,6);
%     bar(mean(AMA),'k'); title(sprintf('AMA: T=%4.3f, p=%0.3f',t.AMA,pAMA)); ylim([min(mean(AMA))-mean(std(AMA)),max(mean(AMA))+mean(std(AMA))])
%     ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
%
%


end

