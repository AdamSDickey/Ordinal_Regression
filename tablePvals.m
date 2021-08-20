data(1).firstAuthor='Gross  - 58 pts';
data(1).countMts=[26 10 7 0];
data(1).countNot=[5 3 4 3];
data(1).source='Figure 2A';
% data(1).countMts=[25 10 7 0];
% data(1).countNot=[5 2 3 1];
% data(1).source='Supp raw data';

data(2).firstAuthor='Donos  - 43 pts';
data(2).countMts=[23 6 5 0];
data(2).countNot=[6 1 2 0];
data(2).source='Extracted from Figure 3B';

data(3).firstAuthor='Youngerman - 30 pts';
data(3).countMts=[10 1 5 2];
data(3).countNot=[7 0 3 2];
data(3).source='Table a & b';

data(4).firstAuthor='Le - 29 pts';
data(4).countMts=[16 4 2 0];
data(4).countNot=[2 2 3 0];
data(4).source='Table 2';

data(5).firstAuthor='Jermakowicz - 23 pts';
data(5).countMts=[11 3 1 0];
data(5).countNot=[5 0 1 2];
data(5).source='Table 1';

data(6).firstAuthor='Grewal - 23 pts';
data(6).countMts=[13 3 2 0];
data(6).countNot=[2 2 1 0];
data(6).source='Table 1 & 2';



data(7).firstAuthor='Tao  - 18 pts with 1 yr outcome';
data(7).countMts=[7 3 0 0];
data(7).countNot=[2 0 3 3];
data(7).source='Table 2';

data(8).firstAuthor='Greenway - 15 pts';
data(8).countMts=[4 1 3 3];
data(8).countNot=[1 0 1 2];
data(8).source='Table 1';

countMtsAll=zeros(1,4);
countNotAll=zeros(1,4);

for j=1:length(data)
    count1=data(j).countMts;
    count2=data(j).countNot;
    
    countMtsAll=countMtsAll+count1;
    countNotAll=countNotAll+count2;
    
    n1=sum(count1);
    n2=sum(count2);
    
    engelMts=[];
    engelNot=[];
    for i=1:4
        engelMts=[engelMts repmat(i,1,count1(i))];
        engelNot=[engelNot repmat(i,1,count2(i))];
    end
    
    x=[ones(1,n1) zeros(1,n2)]'; %indepedent = mts or not?
    y=[engelMts engelNot]'; %depedent Engelranges 1-4
    
    %logistic regresion - binary outcome
    yBinary=y;
    yBinary(y>1)=2; %1 if seizure free, 2 if not
    
    %Multinomial reduces to logistic when given two categories
    [bBin devBin statsBin]= mnrfit(x,yBinary,'model','ordinal','interactions','off');
    yfitBin=mnrval(bBin,[1 0]','model','ordinal');

    %Multinomial regression
    [b dev stats]= mnrfit(x,y,'model','ordinal','interactions','off');
    yfit=mnrval(b,[1 0]','model','ordinal');
    
    pBinary(j)=statsBin.p(end);
    pMulti(j)=stats.p(end);
    
    n(j,2)=n1;
    n(j,3)=n2;
    n(j,1)=n1+n2;
end
%%
disp(n)
disp([pBinary' pMulti'])
disp(countMtsAll)
disp(countNotAll)

%%
table1=[];
for i=1:8
    disp(['#' num2str(i) ' ' data(i).firstAuthor])
    table1(i,1:4)=data(i).countMts;
    table1(i,5:8)=data(i).countNot;
end
table1=[[1:8]' n table1];
disp(' ')
disp('Table')
disp('     Sample Size         |        Engel MTS       |     Engel Non-MTS')
disp('     #   Tot   MTS   Non |  I     II    III   IV  |  I    II    III   IV')
disp(table1)


pVal=[[1:8]' pBinary' pMulti'];
%pVal=round(pVal*100)/100;
disp(' ')
disp('                  P-value')
disp('    #         Binary    Ordinal')
disp(pVal)

%%
pMts=countMtsAll/sum(countMtsAll);
pNot=countNotAll/sum(countNotAll);
