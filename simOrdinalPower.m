function powerSim=simOrdinalPower(n1,n2,countMts,countNot,numRep)
%Example usage
%Ordinal logistic regression achieves 80% power with 120 patients allocated 2:1
%simOrdinalPower(80,40,[110 31 25 5],[30 8 18 12],10000)
%
%Binary logistic regression achievs 80% power with 210 patients allocated 2:1
%simOrdinalPower(140,70,[110 31 25 5],[30 8 18 12],10000)

%Default values
if~exist('n1')
    n1=80;
end
if~exist('n2')
    n2=40;
end

%Pooled from 8 datasets
if~exist('countMts')
    countMts=[110    31    25     5]; 
end
if~exist('countNot')
    countNot=[30     8    18    12];
end
if~exist('numRep')
    numRep=10000;
end

disp([n1 n2])
disp([countMts; countNot])
numRep

p1=countMts/sum(countMts);
p2=countNot/sum(countNot);

pdf1=[0 cumsum(p1)];
pdf2=[0 cumsum(p2)];


%% Simulate

a=rand(numRep,n1);
b=rand(numRep,n2);

sim1=zeros(numRep,n1);
sim2=zeros(numRep,n2);


for i=1:n1
    for j=1:4
        ind=find(a(:,i)>pdf1(j) & a(:,i)<=pdf1(j+1));
        sim1(ind,i)=j;
    end
end

for i=1:n2
    for j=1:4
        ind=find(b(:,i)>pdf2(j) & b(:,i)<=pdf2(j+1));
        sim2(ind,i)=j;
    end
end
    
%%
warning off
tic
x=[ones(1,n1) zeros(1,n2)]';
for i=1:numRep
    if(mod(i,1000)==0)
        disp(i)
    end
    
    ySim=[sim1(i,:) sim2(i,:)];
    yTwoSim=ySim;
    yTwoSim(ySim>1)=2; %ranges 1-2
    
    try
    %dMultinomial with 2 categories  = Logistic
    [bBin devBin statsBin]= mnrfit(x,yTwoSim,'model','ordinal','interactions','off');
    pLogit(i)=statsBin.p(end);

    %Multinomial regression with 4 categories
    [b dev stats]= mnrfit(x,ySim,'model','ordinal','interactions','off');
    pMulti(i)=stats.p(end);
    catch
        disp('Error found, likely that matrix is be positive definite')
        %error in case of no data in one group, which can't be significant
        pLogit(i)=1;
        pMulti(i)=1;
    end
    
end
toc

powerLogit=sum(pLogit<.05)/numRep
powerMulti=sum(pMulti<.05)/numRep
powerSim=[powerLogit powerMulti];


