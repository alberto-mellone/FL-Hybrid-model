%This file generates the figures of active cases and deaths displayed in
%the section "Results" of the manuscript for the German data. Press the run
%button to obtain the figures. Parameters of the model for phase 1 (free 
% phase) and phase 2 (lockdown phase) are saved in the variables
%'est_parameters1' and 'est_parameters2', respectively. The simulation 
%results of active cases, deaths and recovered cases for lockdown 
%percentages of 90%, 60%, 0% and 80% are saved in the first three, 
%second three, third three and last three rows of the variable y.

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

Time=zeros(3,500);
x=zeros(3,500);
y=zeros(3,500);
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
% 4 Different lockdown percentages in L_set are tested
L_set=[0.9 0.6 0 0.8]; % Different lockdown percentages
for i=1:4
lockdown_length =50; 
initial_conditions = x1(:,end);
start_day = 23;
end_day = start_day + lockdown_length; 
L = L_set(i); %lockdown percentage
lambda = 3; %household size
update_days = [23];
identification_windows = [75];
params=[0.521058775877101;0.0657519284449197;0.213597510245136;0.0257933223668323;0.000665727581883234;0.671389223327315;0.191708749960434;0.0141217561841653;0.308146236778204;0.0186419437521085;9.99997955497067];
estimate_params = 0*[0 0 0 0 0 1 1 1 1 1 1]; %parameters are not updated.
weights = [1000 500 100];
[Time2, x2, y2, est_parameters2] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, german_population, data);

s_t(i)=size([Time1 Time2],2);
Time(i,1:s_t(i)) = [Time1 Time2];
y((3*i-2:3*i),1:s_t(i)) = [y1 y2];
x((6*i-5:6*i),1:s_t(i))  = [x1 get_suder(x2)];

end

%--------------------------------plotting----------------------------------
%The results are converted from the fraction of the population to the 
%percentage of the population.
color_set=[0.07,0.62,1.00;1.00,0.00,1.00;1.00,0.00,0.00;0,0,1]; % Different color(RBG value)
%Detected
figure;
hold on; grid on;
xlim([0 80])
ylim([0 0.3])
start_day = 1;

%shadows for free and lockdown phase
shadow1 = patch([0,0,23,23],[0, 0.3,0.3,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow2 = patch([23,23,73,73],[0, 0.3,0.3,0],[0 1 1]);
set(shadow2,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow3 = patch([73,73,247,247],[0, 0.3,0.3,0],[1 1 0.07]);
set(shadow3,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)

%Official data and model
%Convert from fraction to percentage
plot(start_day:end_day, 100*D_measured(start_day:end_day), '--b'); 
for i=1:4
plot(Time(i,1:s_t(i)), 100*y(3*i-2,1:s_t(i)),'color',color_set(i,:) ) %plot with different color
end

xlabel('Time (days)')
ylabel('Cases (percentage of the population)')
title('Predicted active cases: different lockdown percentages')

%construct legend in appropriate order
allChildren = get(gca, 'Children'); 
legend(allChildren([6 7 5 1 4 3 2]),{'Free phase','Lockdown phase','Official data','80%','90%','60%','0%'},'NumColumns',2)
legend('Location','northeast')

%text arrows
ta = annotation('textarrow', [0.3145 0.3545], [0.2183 0.2183]);
ta.String = ['\it\bf23/03/2020',char(10),'(day 23) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.8359 0.8359], [0.4 0.325]);
tb.String = ['\it\bf12/05/2020',char(10),'(day 73) '];              
tb.Color = [0.00 0.45 0.74]; 

set(gca,'layer','top','gridlinestyle','-')

%Death
figure;
hold on; grid on;
xlim([0 80])
ylim([0 0.06])

%shadows for free and lockdown phase
shadow1 = patch([0,0,23,23],[0, 0.6,0.6,0],[1 1 0.07]);
set(shadow1,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow2 = patch([23,23,73,73],[0, 0.6,0.6,0],[0 1 1]);
set(shadow2,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)
shadow3 = patch([73,73,247,247],[0, 0.6,0.6,0],[1 1 0.07]);
set(shadow3,'EdgeColor',[.8 .8 .8],'EdgeAlpha',0.5,'FaceAlpha',0.1)

%Official data and model
%Convert from fraction to percentage
plot(start_day:end_day, 100*E_measured(start_day:end_day), '--b'); 
for i=1:4
plot(Time(i,1:s_t(i)), 100*y(3*i-1,1:s_t(i)),'color',color_set(i,:) ) %plot with different color
end

xlabel('Time (days)')
ylabel('Cases (percentage of the population)')
title('Predicted deaths: different lockdown percentages')

%construct legend in appropriate order
allChildren = get(gca, 'Children'); 
legend(allChildren([6 7 5 1 4 3 2]),{'Free phase','Lockdown phase','Official data','80%','90%','60%','0%'},'NumColumns',2)
legend('Location','northwest')

%text arrows
ta = annotation('textarrow', [0.352 0.352], [0.1917 0.1167]);
ta.String = ['\it\bf23/03/2020',char(10),'(day 23) '];              
ta.Color = [0.00 0.45 0.74];     

tb = annotation('textarrow', [0.8359 0.8359], [0.5298 0.4548]);
tb.String = ['\it\bf12/05/2020',char(10),'(day 73) '];              
tb.Color = [0.00 0.45 0.74];     

set(gca,'layer','top','gridlinestyle','-')