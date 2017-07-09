Mdl = arima ('ARLags', 2, 'D', 1, 'MALags', 1, 'Variance', garch(2,1))
% try different options, for values  next to comma terms, 
%kept garch same
%find best combination for model selection
%additionally use algorithm for future use
%look at paper for optimal model

AB=xlsread('arimadataprice.xlsx');
n=size(AB);  %size of data
n1= n(1,1); % totAl num of rows - selects BPI from data source

n2 = round(n1*0.9); 
% identifies the total num of rows for training data 

n02=n2+1; 
%test data starts from here, moves on 1 from n2 (training data)

%TRAINING DATA
ABT=AB(1:n2,:); % official training data specified with n2
na=size(ABT); %no of rows and columns
na1=na(1,1); %no of rows
ABR=AB(n02:n1, :) 
% specifying test data, starts at no2 variable
%which starts variable from 1 ahead of end of training, ends at 
%end of all data source,

nb=size(ABR); %no of rows and columns of test data
nb1=nb(1,1); % rows in test data used to predict future BPI

%TRAINING MODEL FOR USE OF Bitcoin Price Index FORECASTING
nasadafit=estimate(Mdl, ABT); 
%TRAINING model with training data, 
% estimate function MATLAB

%FORECASTING
[Y, YMSE] = forecast(nasadafit, nb1); 
% forecasting last 147 from nb1 values, test data specified for prediction
% input into MATLAB forecast function is the trained model 'nasadafit'
%  and test data
% forecast output Y = min mean square error forecasts of data
%forecast output YMSE = mean square errors forecasts of conditional mean
%forecast output V = min square error forecasts of coniditonal variannces of future model innovation


sa=AB(na1,1); % variable with function input of training data size
% to bitcoin data column 1

Y1=[sa;Y];
%expected predicted value
%outputs training data, and Y = min square error forecasts of data

ny=size(Y1); %size of above variable
ny1=ny(1,1); % 1st row and col of above variable
k=2;

% 
while k<=ny1
    k1=k-1;
    sg1=Y1(k1,1);
    sg2=sqrt(Y1(k,1));
    Y1(k,1)=sg1+sg2;
    
    
    k=k+1;
end %while k<=ny1
Y1(1,:)=[]; % delete the first row
expectedmeanvalue=mean(abs(Y1));% compare with GRNN
ny=size(Y1);
ny1=ny(1,1);

% calculate upper bound of 95% confidence interval
upper=zeros(ny1,1);
lower=zeros(ny1,1);
kk=1;
while kk<=ny1
    
   ymse1=YMSE(kk,1); 
    
    upper(kk,1)=Y1(kk,1)+1.96*sqrt(ymse1);
    lower(kk,1)=Y1(kk,1)-1.96*sqrt(ymse1);
    kk=kk+1;
end % end of while kk<=ny1


kk=1;
AC=0;
while kk<=ny1
    upper1=upper(kk,1);
    lower1=lower(kk,1);
    actual=ABR(kk,1);
    if actual>=lower1 && actual<=upper1
        AC=AC+1;
    end% if actual>=lower1 && actual<=upper1
    
    kk=kk+1;
end %while kk<=ny1

%Criteria 1: accuracy of model 
Accuracy=(AC/ny1)*100

% Criteria2 for model selection: average difference between upper and lower bound
CC=mean(upper-lower); % lower the value the better: criteria 2

%Actual Test Output = ABR;

%Error_mean = RMSE peformance measurure, ABR (actual) - Y1 predicted
Error_mean=mean(abs(ABR-Y1))

% saving Predicted output Y1 

%xlswrite('\users\sinan707\arimapredictedprice.xlsx', Y1);

%PLOT FOR Actual and Predicted
%predictedvalueontest = Y1
%x=[];
% time strep creation x=(1:1:147)';
%figure
  %  plot(x,Y1,x,ABR)
  
% PLOT FOR 95% Interval
 % x=[];
 %x=(1:1:147)';
 %figure
 %plot(x, upper, x, Y1, x, ABR, x, lower)