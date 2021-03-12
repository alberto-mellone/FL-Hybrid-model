%This file generates the figures of active cases and deaths displayed in
%the section "Results" of the manuscript for the Israeli data. Press the run
%button to obtain the figures. Parameters of the model for phase 1 (free 
% phase), phase 2 (lockdown phase), phase 3 (free phase, after 
%lifting of the lockdown) and phase 4 (second lockdown phase) are saved in 
%the variables 'est_parameters1', 'est_parameters2', 'est_parameters3' and 
%'est_parameters4' respectively. The simulation results of active cases, 
%deaths and recovered cases are saved in the first, second and last row of 
%the variable y.

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
lockdown_length = 30;
initial_conditions = x1(:,end);
start_day = 183;
end_day = start_day + lockdown_length; %Oct 18th
L=0.65; %lockdown percentage
lambda = 3; %household size
update_days = [183];
identification_windows = [30];
params=[0.441783040426239;0.160982579149557;0.205017874474453;0.0546200364243093;0.000567124631667484;0.495160995355358;0.164247793757103;0.0317167864638388;0.366578884284997;0.00162752179563438;8.68219741279234];
estimate_params=[0 0 0 0 0 1 1 1 1 1 1]*0; %parameters are not updated.
weights = [150 250 10];
[Time2, x2, y2, est_parameters2] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, Israel_population, data);

%--------------------------Lockdown lifted----------------------------
x2_suder = get_suder(x2);
initial_conditions = x2_suder(:,end);
estimate_undetected = 0;
start_day = end_day; 
end_day = 283;
update_days = [start_day 220 230 250 270];
identification_windows = [40 20 30 20 20]; 
weights=[150,1450,10;10,100,5;15,1000,5;15,1000,5;15,1000,5]; %weights matrix
params = [0.5; 0.1; 0.2; 0.03; 0.01]; %parameters guess
estimate_params =[1 1 1 1 1]*1; %estimate all parameters
[Time3, x3, y3, est_parameters3] = simulate_suder_Israel(initial_conditions, estimate_undetected, start_day, end_day, update_days, identification_windows, params, estimate_params, weights, data);

%------------------------------Second Lockdown-----------------------------
% Parameters of free parts are same with the latest parameters before lockdown.  
% Parameters of lockdown parts are same with first lockdown.
lockdown_length = 15; %predict 15 days
initial_conditions = x3(:,end);
start_day = 283;
end_day = start_day + lockdown_length; 
L = 0.60; %lockdown percentage
lambda = 3; %household size
update_days = [283];
identification_windows = [36];
params = [0.366686460949212;0.168397879555386;0.119111790032470;0.0750865991622122;0.000676001569932565;0.495160995355358;0.164247793757103;0.0317167864638388*1;0.366578884284997;0.00162752179563438*1;8.68219741279234];
estimate_params =[0 0 0 0 0 0 0 0 0 0 0];% parameters are not estimated
weights = [450 250 150];
[Time4, x4, y4, est_parameters4] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, Israel_population, data);
Time = [Time1 Time2 Time3 Time4];
y = [y1 y2 y3 y4];
x = [x1 get_suder(x2) x3 get_suder(x4)];
start_day = 1;
end_day = 319;
%--------------------------------plotting----------------------------------
%The results are converted from the fraction of the population to the 
%percentage of the population.
%Detected
figure;
hold on; grid on;
xlim([0 310])
ylim([0 1])

%shadows for free and lockdown phase
shadow1 = patch([0,0,183,183],[0,1,1,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow2 = patch([183,183,213,213],[0,1,1,0],[0 1 1]);
set(shadow2,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow3 = patch([213,213,283,283],[0,1,1,0],[1 1 0.07]);
set(shadow3,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow4 = patch([283,283,310,310],[0,1,1,0],[0.72,0.27,1.00]);
set(shadow4,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)

%Official data and model
%Convert from fraction to percentage
D_data=plot(start_day:end_day, 100*D_measured(start_day:end_day), '--b');
D_model=plot(Time, 100*y(1,:), 'b');
xlabel('Time (days)')
ylabel('Cases (percentage of the population)')
title('Predicted active cases: second lockdown')
legend([shadow1 shadow2 shadow4 D_data D_model],{'Free phase','Lockdown phase (fitting)','Lockdown phase (prediction)','Official data','Model'})
legend('Location','northwest')

%text arrows
ta = annotation('textarrow', [0.5457 0.5857], [0.5814 0.5814]);
ta.String = ['\it\bf18/09/2020',char(10),'(day 183) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.6091 0.6591], [0.2993 0.3493]);
tb.String = ['\it\bf18/10/2020',char(10),'(day 213) '];              
tb.Color = [0.00 0.45 0.74];     

tc = annotation('textarrow', [0.7957 0.8357], [0.4314 0.4314]);
tc.String = ['\it\bf27/12/2020',char(10),'(day 283) '];              
tc.Color = [0.00 0.45 0.74];  

set(gca,'layer','top','gridlinestyle','-')

%Death 
figure;
hold on; grid on;
xlim([0 310])
ylim([0 0.05])

%shadows for free and lockdown phase
shadow1 = patch([0,0,183,183],[0, 0.05,0.05,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow2 = patch([183,183,213,213],[0, 0.05,0.05,0],[0 1 1]);
set(shadow2,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow3 = patch([213,213,283,283],[0, 0.05,0.05,0],[1 1 0.07]);
set(shadow3,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow4 = patch([283,283,310,310],[0,0.05,0.05,0],[0.72,0.27,1.00]);
set(shadow4,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)

%Official data and model
%Convert from fraction to percentage
E_data=plot(start_day:end_day, 100*E_measured(start_day:end_day), '--r');
E_model=plot(Time, 100*y(2,:), 'r');
xlabel('Time (days)')
ylabel('Cases (percentage of the population)')
title('Predicted deaths: second lockdown')
legend([shadow1 shadow2 shadow4 E_data E_model],{'Free phase','Lockdown phase (fitting)','Lockdown phase (prediction)','Official data','Model'})
legend('Location','northwest')

%text arrows
ta = annotation('textarrow', [0.5439 0.5839], [0.3398 0.3398]);
ta.String = ['\it\bf18/09/2020',char(10),'(day 183) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.6207 0.6607], [0.5160 0.5160]);
tb.String = ['\it\bf18/10/2020',char(10),'(day 213) '];              
tb.Color = [0.00 0.45 0.74];     

tc = annotation('textarrow', [0.7957 0.8357], [0.6921 0.6921]);
tc.String = ['\it\bf27/12/2020',char(10),'(day 283) '];              
tc.Color = [0.00 0.45 0.74];  

set(gca,'layer','top','gridlinestyle','-')

% Recovered:
% figure
% plot(Time, y(3,:),'g')
% hold on; grid on;
% plot(start_day:end_day, Rd_measured(start_day:end_day), '--g');


