%{ 
Generalized Regression Neural Network for predicting
Bitcoin Price Index

Toolboxes used: 
- Neural Networks
- Econometrics
- Statistics
%}

% Data Retreival
%a=xlsread('/homes/sd313/Desktop/MATLAB/arimadata.xlsx');% reads data
 
 %reads data BCU Z DRIVE 
 a=xlsread('Z:\GRNN\arimadata.xlsx'); 


% Data Processing
a(1,:)=[];
n=size(a); %size of data set = 1471 observations of BPI
n1=n(1,1); % first row and column of vectorized data set of TOTAL OBSEVRATIONS
n11=n1-1; % removes first observation 0 from time-series, as interfering with process
%total observations are now 1470

% DATA DIVISION: Training
n333=round(n1*0.9); %training data
%uses 90% of 1470 observations

%{
 DATA DIVISION: Testing
 Start Test data from first observation after the end of training data
 set, variable n33
%}

% Test Data: actualoutput
n334=n333+1; %  start of tests data used for prediciting data
actualoutput=a(n334:n1,:);% start test data at n334 and finish at end of data set

%DATA PROCESSING: DIFFERENCING
X=a(1:n11,:)% all data SET from 1 untill end - FIRST DIVISION OF DATA SPLITTING
X11=X(n11,1); %all data into x parsed n11 - TOTAL OBSERVATIONS, column 1
X1=mean(X); %mean data of
Y=a(2:n1,:); % SECOND DIVISION OF DATA SPLITTING
y1=mean(Y); % split data set and mean 
dd=X-Y; % differeneced mean stationary series - PLOT!!!
n=size(dd); % size =  of differenced mean stationary row vector of dd

n1=n(1,1); % new data set
n11=n1-1; % above data set -1

% rolling one step forecast, divides data into 2
xx=dd(1:n11,:);
yy=dd(2:n1,:);
nx=size(xx);
nx1=nx(1,1);
nd=round(nx1*0.9); %training data
nd1=nd+1; % start of test data
traininginput=xx(1:nd,:);% training data inputed to variable
np=size(traininginput); %vectorizes training input data WITH SIZE
% 1323 observations of training

%Learning: rolling one step forecast
% starts at +1 of training set
testinput=xx(nd1:nx1,:); % test data input,ends on data set
trainingoutput=yy(1:nd,:);% output of data to learn and help predict
%starts at row of training data and ends

testoutput=yy(nd1:nx1,:); %actual output - start at test data  untill end
%output of data to learn and help predict

%rolling 1 step ahead learning for training to predict
P=traininginput'; %starting at xxtransposed training data into column
T=trainingoutput';%transposed training data into column

%MODEL SELECTION
%grnn creation for given inputs P and T
net = newgrnn(P,T,2.3);% change 3rd value spread to select best model, make table
% default spread is 1. was 0.5
%first layer weights set to 'P' and first layer biases are 0.8326/spread
%second layer weights set to T

nj=size(testinput); % vectorizes testinput into nj
nj1=nj(1,1); % predicted output 147 obs - Transforming orignal scale as differenced b4
%done due to variance stationarity

k=1;
v=[];
predictedoutput=[];
predictedoutput=zeros(nj1,1); %zeros matrix testinput

while k<=nj1 % iterates through testinput data to train.
    % nj1 is test data, keeps looping untill end
    
    nds=size(traininginput); %training input size
    nds1=nds(1,1); % vectorized training input
    q=traininginput(nds1,1) ; %trainingput takes training input row  as parse
    v=sim(net,q); %sim function matlab, simulates GRNN 
    % by parsing net, selected model
    % which has lowest RMSE , whis is
    % selected GRNN, and training input
    %simulated GRNN for prediction iteration for new input 'q' ?
    predictedoutput(k,1)=v; %simulated network
    traininginput=[traininginput;v] ;% actual and GRRN model
    k=k+1; % identfies when loop has finished iteration
    
end %while l<= nj1

ug=predictedoutput(1,1)+X11;
predictedoutput(1,1)=ug;
k=2;
while k<=nj1 % whilse k is less or equal to test data size (147)
    j=k-1; 
    g=predictedoutput(j,1); %moves through test data
    
    h=predictedoutput(k,1)+g; % performing prediction
    predictedoutput(k,1)=h; %predicted output
    
    
    k=k+1; % ensures to stop loop at end of test data
end %while k<=nj1

%point estimate of predicted output of 147 observations for future BPI
xlswrite('Z:\GRNN\predictedoutput.xlsx',predictedoutput); 
% BCU file student z drive location for prediction

% predicted outtput and actual output

% Performance Measure RMSE 
% compare with arima - Difference between predicted and actual ouputs
Differecemean=mean(abs(actualoutput-predictedoutput));

%predictedouput - point estimation
%ACTUAL and PREDICTED PLots of BPI 
sizeofpredictedouput = size(predictedoutput)
x=[];
x=(1:1:147)';
xxx=actualoutput;
yyy=predictedoutput;

figure
plot(x,xxx,x,yyy) 

%acf and pacf plots for dd(differenced series) and a (orignal price) variable
%{
figure
subplot(2,1,1)
autocorr(dd)
subplot(2,1,2)
parcorr(dd)
%volatility
%}
%{
vs=sim(net,P);
vs1=vs';
%squared difference between predicted training output and actual training output
SE=(trainingoutput-vs1).^2;
nse=size(SE);
nse1=nse(1,1);
nse2=nse1-1;
tr1=SE(1:nse2,:);% training input for volatility prediction
ts1=SE(2:nse1,:); % training output for volatility prediction
netvol=newgrnn(tr1,ts1);
predictedoutputv=zeros(nj1,1);
nj=size(tr1);
nj1=nj(1,1);
while k<=nj1
    
    nds=size(tr1);
    nds1=nds(1,1);
    q=tr1(nds1,1);
    v=sim(net,q);
    predictedoutputv(k,1)=v;
    tr1=[tr1;v];
    k=k+1;
    
end %while l<= nj
%}


