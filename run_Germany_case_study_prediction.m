%This file generates the figures of active cases and deaths displayed in
%the section "Results" of the manuscript for the German data. Press the run
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
german_population= 83e06;
data = get_data('Germany.csv', german_population);

D_measured = data.OutputData(:,1)';
E_measured = data.OutputData(:,2)';
Rd_measured = data.OutputData(:,3)';

% ----------------Start of the epidemic (free phase)----------------------
% Initial conditions
U0 = 200/german_population;
D0 = D_measured(1);
E0 = E_measured(1);
Ru0 = 0;
Rd0 = Rd_measured(1);
S0 = 1 - U0 -D0 - E0 - Ru0 - Rd0;

initial_conditions = [S0 U0 D0 E0 Ru0 Rd0]';
estimate_undetected = 0; % do not estimate the initial condition
start_day = 1; %01/03/2020
end_day = 23;
update_days = [1];
identification_windows = [22];
params = [0.521058775877101;0.0657519284449197;0.213597510245136;0.0257933223668323;0.000665727581883234]; %parameters for free phase
estimate_params = 0*[1 1 1 1 1];%parameters are not updated in this free phase of 23 days 
weights = [10000 1000 1000];
[Time1, x1, y1, est_parameters1] = simulate_suder_Germany(initial_conditions, estimate_undetected, start_day, end_day, update_days, identification_windows, params, estimate_params, weights, data);

% ---------------------------First Lockdown--------------------------------
% Parameters of free parts are same with the latest parameters before lockdown.  
% Parameters of lockdown parts are estimated only once at the beginning.
lockdown_length =50; 
initial_conditions = x1(:,end);
start_day = 23;
end_day = start_day + lockdown_length; 
L = 0.8; %lockdown percentage
lambda = 3; %household size
update_days = [23];
identification_windows = [75];
params=[0.521058775877101;0.0657519284449197;0.213597510245136;0.0257933223668323;0.000665727581883234;0.671389223327315;0.191708749960434;0.0141217561841653;0.308146236778204;0.0186419437521085;9.99997955497067];
estimate_params = 0*[0 0 0 0 0 1 1 1 1 1 1]; %parameters are not updated.
weights = [1000 500 100];
[Time2, x2, y2, est_parameters2] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, german_population, data);

%--------------------------Lockdown lifted----------------------------
x2_suder = get_suder(x2);
initial_conditions = x2_suder(:,end);
estimate_undetected = 0;
start_day = end_day;
end_day = 247;
update_days =[start_day 90 100 120 150 180 200 220];
identification_windows = [100 30 40 60 40 40 20 30];
params=[0.361262892473732;0.224540691117907;0.134126871644314;0.0682772597218284;0.00370867513396669];
estimate_params = 1*[1 1 1 1 1]; %estimate all parameters
% weight matrix
for k=1:10
    if k<3
weights(k,:) = [150,150,10];
    elseif k==3
weights(k,:) = [1500,1300,50];
    else 
weights(k,:) = [500,500,20];
    end
end
[Time3, x3, y3, est_parameters3] = simulate_suder_Germany(initial_conditions, estimate_undetected, start_day, end_day, update_days, identification_windows, params, estimate_params, weights, data);

%------------------------------Second Lockdown-----------------------------
% Parameters of free parts are same with the latest parameters before lockdown.  
% Parameters of lockdown parts are same with first lockdown except death rates
lockdown_length =15; %predict 15 days
initial_conditions = x3(:,end);
start_day = 247;
end_day = start_day + lockdown_length; 
L = 0.70; %lockdown percentage
lambda = 3; %household size
update_days = [247];
identification_windows = [25];
params=[0.421446207769596;0.251190964551425;0.0951137299329282;0.0448070585043152;0.000490318927013205;0.671389223327315;0.191708749960434;0.0141217561841653;0.308146236778204;0.00328974419737024;9.99997955497067];
estimate_params = [0 0 0 0 0 0 0 0 0 0 0]; %parameters are not estimated
weights = [100 1000 1];
[Time4, x4, y4, est_parameters4] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, german_population, data);
Time = [Time1 Time2 Time3 Time4];
y = [y1 y2 y3 y4];
x = [x1 get_suder(x2) x3 get_suder(x4)];
start_day = 1;
end_day = 269;

%--------------------------------plotting----------------------------------
%The results are converted from the fraction of the population to the 
%percentage of the population.

%Detected
figure;
hold on; grid on;
xlim([0 269])
ylim([0 0.4])

%shadows for free and lockdown phase
shadow1 = patch([0,0,23,23],[0, 0.4,0.4,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow2 = patch([23,23,73,73],[0, 0.4,0.4,0],[0 1 1]);
set(shadow2,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow3 = patch([73,73,247,247],[0, 0.4,0.4,0],[1 1 0.07]);
set(shadow3,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow4 = patch([247,247,269,269],[0, 0.4,0.4,0],[0.72,0.27,1.00]);
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
ta = annotation('textarrow', [0.1948 0.1948], [0.2893 0.2143]);
ta.String = ['\it\bf23/03/2020',char(10),'(day 23) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.3386 0.3386], [0.2369 0.1619]);
tb.String = ['\it\bf12/05/2020',char(10),'(day 73) '];              
tb.Color = [0.00 0.45 0.74];     

tc = annotation('textarrow', [0.8002 0.8402], [0.5683 0.5683]);
tc.String = ['\it\bf02/11/2020',char(10),'(day 247) '];              
tc.Color = [0.00 0.45 0.74];  

set(gca,'layer','top','gridlinestyle','-')

%Death
figure; 
hold on; grid on;
xlim([0 269])
ylim([0 0.02])

%shadows for free and lockdown phase
shadow1 = patch([0,0,23,23],[0, 0.02,0.02,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow2 = patch([23,23,73,73],[0, 0.02,0.02,0],[0 1 1]);
set(shadow2,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow3 = patch([73,73,247,247],[0, 0.02,0.02,0],[1 1 0.07]);
set(shadow3,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow4 = patch([247,247,269,269],[0, 0.02,0.02,0],[0.72,0.27,1.00]);
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
ta = annotation('textarrow', [0.1939 0.1939], [0.2702 0.1702]);
ta.String = ['\it\bf23/03/2020',char(10),'(day 23) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.2993 0.3393], [0.491 0.491]);
tb.String = ['\it\bf12/05/2020',char(10),'(day 73) '];              
tb.Color = [0.00 0.45 0.74];     

tc = annotation('textarrow', [0.7984 0.8384], [0.6338 0.6338]);
tc.String = ['\it\bf02/11/2020',char(10),'(day 247) '];              
tc.Color = [0.00 0.45 0.74];  

set(gca,'layer','top','gridlinestyle','-')

% figure; hold on; grid on
% plot(Time, y(3,:),'g')
% plot(start_day:end_day, Rd_measured(start_day:end_day), '--g');

