%From Table 1 - tablePvals.m
nMts=[43    34    18    22    15    18    10    11];
nNot=[15     9    12     7     8     5     8     4];



data(1).firstAuthor='Gross  - 58 pts';
data(2).firstAuthor='Donos  - 43 pts';
data(3).firstAuthor='Youngerman - 30 pts';
data(4).firstAuthor='Le - 29 pts';
data(5).firstAuthor='Jermakowicz - 23 pts';
data(6).firstAuthor='Grewal - 23 pts';
data(7).firstAuthor='Tao  - 18 pts with 1 yr outcome';
data(8).firstAuthor='Greenway - 15 pts';

disp(' ')
%Pooled 8 datasets

countMts=[110    31    25     5];
countNot=[30     8    18    12];
disp('Engel I-VI, MTS vs not')
disp([countMts; countNot])
disp(' ')

numRep=10000;

wantSim=0 %uncomment to load previous simulated data
%wantSim=1 %uncomment to re-run simulation

%%
if(wantSim)
    disp('Simulating - takes 6 minutes with 10,000 repetitions')
    t=tic;
    for i=1:8
        disp(' ')
        disp(i)
        disp(data(i).firstAuthor)
        powerAll(i,:)=simOrdinalPower(nMts(i),nNot(i),countMts,countNot,numRep);
        
    end
    toc(t)
    
    save dataPowerSim countMts countNot numRep powerAll nMts nNot
end
    
%%
load dataPowerSim
powerPerc=round(powerAll*100);

for i=1:8
    disp(['#' num2str(i) ' ' data(i).firstAuthor])
end

%pVal=round(pVal*100)/100;
disp(' ')
disp('Table')
disp('                          | Power (%)')
disp('     #    Tot   MTS   Non | Bin   Ord')
disp([[1:8]' nMts'+nNot' nMts' nNot' powerPerc])

meanPower=mean(powerAll*100)
[h pPower]=ttest(powerAll(:,1),powerAll(:,2));
pPower
