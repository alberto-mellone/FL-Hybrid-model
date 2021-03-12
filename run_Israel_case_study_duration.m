%This file generates the figures of active cases and deaths displayed in
%the section "Results" of the manuscript for the Israeli data. Press the run
%button to obtain the figures. Parameters of the model for phase 1 (free 
% phase), phase 2 (lockdown phase) and phase 3 (free phase, after 
%lifting of the lockdown) are saved in the variables 'est_parameters1',
%'est_parameters2' and 'est_parameters3', respectively. The simulation
%results of active cases, deaths and recovered cases for lockdown durations 
%of 50 days, 20 days and 30 days are saved in the first three, second three 
%and last three rows of the variable y.

clc
clear 
close all
warning off
%estimation data setup
Israel_population = 9e6;
data = get_data('Israel.csv', Israel_population);

D_measured = data.OutputData(:,1)';
E_measured = data.OutputData(:,2)';
Rd_measured = data.OutputData(:,3)';

Time=zeros(3,500);
x=zeros(3,500);
y=zeros(3,500);
% ----------------Start of the epidemic (free phase)----------------------
% Initial conditions
U0 = 1600/Israel_population;
D0 = D_measured(1);
E0 = E_measured(1);
Ru0 = 0;
Rd0 = Rd_measured(1);
S0 = 1 - U0 -D0 - E0 - Ru0 - Rd0;

initial_conditions = [S0 U0 D0 E0 Ru0 Rd0]';
estimate_undetected = 0; % do not estimate the initial condition
start_day = 1; %20/03/2020
end_day =183;  
update_days = [1 10 20 40 60 80 121 165];
identification_windows = [20 10 50 20 20 40 40 15];
weights=[10,105,1;15,50,1;50,50,10;25,50,10;1000,200,20;50,350,10;50,150,10;10,100,10]; %weights matrix
params = [0.6; 0.1; 0.3; 0.05; 0.001]; %parameters guess
estimate_params = [1 1 1 1 1]; %estimate all parameters
[Time1, x1, y1, est_parameters1] = simulate_suder_Israel(initial_conditions, estimate_undetected, start_day, end_day, update_days, identification_windows, params, estimate_params, weights, data);

% ---------------------------First Lockdown--------------------------------
% Parameters of free parts are same with the latest parameters before lockdown.  
% Parameters of lockdown parts are estimated only once at the beginning.
% 3 Different lockdown duartions in duration_set are tested
duration_set=[50 20 30]; % Different lockdown durations
for i=1:3
lockdown_length = duration_set(i);
initial_conditions = x1(:,end);
start_day = 183;
end_day = start_day + lockdown_length; 
L=0.65; %lockdown percentage
lambda = 3; %household size
update_days = [183];
identification_windows = [30];
params=[0.441783040426239;0.160982579149557;0.205017874474453;0.0546200364243093;0.000567124631667484;0.495160995355358;0.164247793757103;0.0317167864638388;0.366578884284997;0.00162752179563438;8.68219741279234];
estimate_params=[0 0 0 0 0 1 1 1 1 1 1]*0; %parameters are not updated.
weights = [150 250 10];
[Time2, x2, y2, est_parameters2] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, Israel_population, data);

%---------------------------Lockdown lifted-------------------------
x2_suder = get_suder(x2);
initial_conditions = x2_suder(:,end);% convert states from lockdown to free 
estimate_undetected = 0;
start_day = end_day; 
end_day = start_day+30; %evolution of 30days
update_days = [start_day];
identification_windows = [40]; 
weights=[150,1450,10;10,100,5;15,1000,5;15,1000,5;15,1000,5]; %weights matrix
params = [0.303430140833981;0.178663221347180;0.100000103504120;0.101199883283739;0.00135623980936670];
estimate_params =[1 1 1 1 1]*0; %parameters are not updated
[Time3, x3, y3, est_parameters3] = simulate_suder_Israel(initial_conditions, estimate_undetected, start_day, end_day, update_days, identification_windows, params, estimate_params, weights, data);

s_t(i)=size([Time1 Time2 Time3],2);

Time(i,1:s_t(i)) = [Time1 Time2 Time3];
y((3*i-2:3*i),1:s_t(i)) = [y1 y2 y3];
x((6*i-5:6*i),1:s_t(i))  = [x1 get_suder(x2) x3];

end



%%--------------------------------plotting----------------------------------
%The results are converted from the fraction of the population to the 
%percentage of the population.
color_set=[0.07,0.62,1.00;1.00,0.00,0.00;0,0,1]; % Different color(RBG value)
%Detected
figure;
hold on; grid on;
xlim([160 270])
ylim([0 0.8])
start_day = 1;
end_day = 270;

%shadows for free and lockdown phase
shadow1 = patch([0,0,183,183],[0, 0.8,0.8,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)

%Official data and model
%Convert from fraction to percentage
plot(start_day:end_day, 100*D_measured(start_day:end_day), '--b'); 
for i=1:3
plot(Time(i,1:s_t(i)), 100*y(3*i-2,1:s_t(i)),'color',color_set(i,:) ) %plot with different color
end

xlabel('Time (days)')
ylabel('Cases (percentage of the population)')
title('Predicted active cases: different lockdown durations')

%construct legend in appropriate order
allChildren = get(gca, 'Children'); 
legend(allChildren([5 4 1 3 2]),{'Free phase','Official data','30 days','50 days','20 days'})
legend('Location','northeast')

%text arrows
ta = annotation('textarrow', [0.2555 0.2955], [0.7017 0.7017]);
ta.String = ['\it\bf18/09/2020',char(10),'(day 183) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.46 0.5], [0.4052 0.4052]);
tb.String = ['\it\bf18/10/2020',char(10),'(day 213) '];              
tb.Color = [0.00 0.45 0.74];     

tc = annotation('textarrow', [0.5948 0.6348], [0.1779 0.1779]);
tc.String = ['\it\bf07/11/2020',char(10),'(day 233) '];              
tc.Color = [0.00 0.45 0.74];     

td = annotation('textarrow', [0.4936 0.4536], [0.6838 0.6838]);
td.String = ['\it\bf08/10/2020',char(10),'(day 203) '];              
td.Color = [0.00 0.45 0.74];   

set(gca,'layer','top','gridlinestyle','-')

figure;
hold on; grid on;
xlim([160 270])
ylim([0 0.04])

%shadows for free and lockdown phase
shadow1 = patch([0,0,183,183],[0, 0.04,0.04,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)

%Official data and model
%Convert from fraction to percentage
plot(start_day:end_day, 100*E_measured(start_day:end_day), '--b'); 
for i=1:3
plot(Time(i,1:s_t(i)), 100*y(3*i-1,1:s_t(i)),'color',color_set(i,:) ) %plot with different color
end

xlabel('Time (days)')
ylabel('Cases (percentage of the population)')
title('Predicted deaths: different lockdown durations')

%construct legend in appropriate order
allChildren = get(gca, 'Children'); 
legend(allChildren([5 4 1 3 2]),{'Free phase','Official data','30 days','50 days','20 days'})
legend('Location','northwest')

%text arrows
ta = annotation('textarrow', [0.292 0.292], [0.481 0.406]);
ta.String = ['\it\bf18/09/2020',char(10),'(day 183) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.5062 0.5062], [0.5405 0.6155]);
tb.String = ['\it\bf18/10/2020',char(10),'(day 213) '];              
tb.Color = [0.00 0.45 0.74];     

tc = annotation('textarrow', [0.6482 0.6482], [0.5726 0.6476]);
tc.String = ['\it\bf07/11/2020',char(10),'(day 233) '];              
tc.Color = [0.00 0.45 0.74];     

td = annotation('textarrow', [0.4241 0.4241], [0.6619 0.5869]);
td.String = ['\it\bf08/10/2020',char(10),'(day 203) '];              
td.Color = [0.00 0.45 0.74];

set(gca,'layer','top','gridlinestyle','-')