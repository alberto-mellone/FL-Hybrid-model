function [Time, x, y, est_parameters] = simulate_suder(initial_conditions, estimate_undetected, start_day, end_day, update_days, identification_windows, params, estimate_params, weights, data)
% Initial conditions specified as a vector [S0 U0 D0 E0 Ru0 Rd0]
% start_day and end_day of the lockdown
% L is the lockdown percentage
% lambda is the average household size
% update_days is a vector of the days at which the parameters need to be
% updated -- MUST INCLUDE THE FIRST DAY OF LOCKDOWN
% identification_window is the window of days in the future used to
% estimate the model parameters on one of the update days
% data is the official data 

if start_day >= end_day
    error('Start day must be smaller than end day');
end

if update_days(1) ~= start_day
    error('FIrst update must happen on the first day of lockdown');
end

for i = 1:length(update_days)-1
    if update_days(i)>= update_days(i+1)
        error('Update days must be strictly increasing');
    end
end

%% Grey box model setup
%orders
Nx = 6;
Ny = 3;
Nu = 0;
Np = 5;

Ts = 0;    %continuous-time model

model_name = 'suder_model';
order = [Ny Nu Nx];

initial_conditions_guess = initial_conditions;

parameters_guess = params;


x = [];
Time = [];
est_parameters = [];

d = 1; %iterator on update_days

for i=start_day:end_day
    
    if i == update_days(d)
        
        nlgr = idnlgrey(model_name,order,parameters_guess,initial_conditions_guess, Ts); %grey-box model

        for n = 1:Nx
            nlgr.InitialStates(n).Fixed = true;
        end
        if d == 1 && estimate_undetected
            nlgr.InitialStates(2).Fixed = false;
            nlgr.InitialStates(2).Minimum = 0;
        end
        
        for n = 1:Np
            if estimate_params(n)
                if n==2
                nlgr.Parameters(n).Minimum =0;
                nlgr.Parameters(n).Maximum =0.3;
                elseif n==3
                nlgr.Parameters(n).Minimum =0.1;
                nlgr.Parameters(n).Maximum =1;
                else
                nlgr.Parameters(n).Minimum =0;
                nlgr.Parameters(n).Maximum = 1;
                end
            
            else
                nlgr.Parameters(n).Fixed = true;
                
            end
        end
        
        W = eye(Ny);
        W(1,1) = weights(d,1);
        W(2,2) = weights(d,2);
        W(3,3) = weights(d,3);
        data_temp = data(i:i+identification_windows(d),:,:);
        opt = nlgreyestOptions('EstimateCovariance', false, 'OutputWeight', W);
        m = nlgreyest(data_temp, nlgr,opt);
        % opt = nlgreyestOptions('SearchMethod', 'fmincon');
        % opt.SearchOptions.Algorithm = 'sqp';
        % m = nlgreyest(data_temp, nlgr,opt);

        parameters_guess = zeros(1,Np);
        for n = 1:Np
            parameters_guess(n) = m.Parameters(n).Value;
        end
        
        x0 = zeros(Nx,1);
        for n = 1:Nx
            x0(n) = m.InitialStates(n).Value;
        end
        
        if d == length(update_days)
            [Time_temp, x_temp] = ode45(@(t,x) SUDER(t,x, parameters_guess), [i, end_day], x0);
        else
            [Time_temp, x_temp] = ode45(@(t,x) SUDER(t,x, parameters_guess), [i, update_days(d+1)], x0);
        end

        if i == start_day
            x = x_temp';
            Time = Time_temp';
            est_parameters = parameters_guess'*ones(1,Np);
        else
            x = [x(:,1:end-1), x_temp'];
            Time = [Time(1:end-1), Time_temp'];
            est_parameters = [est_parameters(:,1:end-1) parameters_guess'*ones(1,Np)];
        end
        
        initial_conditions_guess = x(:,end);
        d = d+1;
        
        if d > length(update_days)
            break;
        end
    end
end

y = [x(3,:); x(4,:); x(6,:)];

end