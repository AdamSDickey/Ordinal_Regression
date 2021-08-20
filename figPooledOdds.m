%Pooled across 8 studies
countMts=[110    31    25     5]; 
countNot=[30     8    18    12];


n1=sum(countMts);
n2=sum(countNot);
p1=countMts/sum(n1);
p2=countNot/sum(n2);

engelMts=[];
engelNot=[];
for i=1:4
    engelMts=[engelMts repmat(i,1,countMts(i))];
    engelNot=[engelNot repmat(i,1,countNot(i))];
end

hasMts=[ones(1,n1) zeros(1,n2)]'; %indepedent = mts or not?
engel=[engelMts engelNot]'; %depedent Engelranges 1-4

%Ordinal regression
[b dev stats]= mnrfit(hasMts,engel,'model','ordinal','interactions','off');

yObs=[p1; p2]
yfit=mnrval(b,[1 0]','model','ordinal')

pooled=b(end);
poolSe=stats.se(end);
pooledInt=exp([pooled-1.96*poolSe pooled pooled+1.96*poolSe]);

%% Fit three logistic regressions

for i=1:3
    engelGood=engel<=i;
    n=n1+n2;
    nBin=ones(n,1);
    
    [bBin devBin statsBin] = glmfit(hasMts, [engelGood nBin], 'binomial', 'link', 'logit');
    yBinfit = glmval(bBin, [0 1], 'logit', 'size', [1 1]);
    disp(yBinfit)
    
    logOdds(i)=bBin(end);
    se(i)=statsBin.se(end);
    logitInt(i,:)=exp([logOdds(i)-1.96*se(i) logOdds(i) logOdds(i)+1.96*se(i)]);
end



%% Figure 1 - Observed vs. fit
figure
subplot(211)
%bar([1:4],[count1' count2'],'stacked')
bar([1:4],100*[p1; p2]')
%xlabel('Engel Class')
ylabel('% of patients')
legend('MTS','Non MTS')
ylim([0 100])
set(gca,'box','off')

subplot(212)
bar([1:4],100*[yfit]')
xlabel('Engel Class')
ylabel('% of patients')
legend('Fit MTS','Fit Non')
ylim([0 100])
set(gca,'box','off')

%shrink
p=get(gcf,'Position');
p(3:4)=p(3:4)*.45;
set(gcf,'Position',p)



%% Figure 2 - Odds ratio, logistic vs. pooled
figure
hold on
plot(logitInt(:,2),[1 2 3],'ro')
for i=1:3
    plot(logitInt(i,[1 3]),[i i],'r-')
end
ylim([-1 4])
plot(pooledInt(2),0,'bd')
%xlim([0 22])
plot([pooledInt(1) pooledInt(3)],[0 0],'b-')

xlabel('Odds Ratio')
set(gca,'YTick',[0 1 2 3])
set(gca,'YTickLabel',[' Pooled ';'1 vs 234';'12 vs 34';'123 vs 4'])
xlim([0 22])

%shrink
p=get(gcf,'Position');
p(3)=p(3)*.45;
p(4)=p(4)*.35;
set(gcf,'Position',p)


