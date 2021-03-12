function [Time, x, y, est_parameters] = simulate_lockdown(initial_conditions, start_day, end_day, L, lambda, update_days, identification_windows, params, estimate_params, weights, population, data)
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
Nx = 22;
Ny = 3;
Nu = 0;
Np = 12;

Ts = 0;    %continuous-time model

model_name = 'lockdown_model';
order = [Ny Nu Nx];

S0 = initial_conditions(1);
U0 = initial_conditions(2);
D0 = initial_conditions(3);
E0 = initial_conditions(4);
Ru0 = initial_conditions(5);
Rd0 = initial_conditions(6);

%free population
Uf0 = (1-L)*U0;
Sf0 = (1-L)*S0;
Df0 = D0;
Ef0 = E0;
Ruf0 = Ru0;
Rdf0 = Rd0;

%lockdown population
N_households = (S0 + U0)*L*population/lambda;

a1 = 1e-5;
[a0, a2, a3] = alpha_computation(S0, U0, a1, lambda);

H0_0 = a0*N_households;
U1_0 = a1*N_households/population;
U2_0 = 2*a2*N_households/population;
U3_0 = 3*a3*N_households/population;

initial_conditions_guess = zeros(Nx,1);
initial_conditions_guess(1) = Sf0;
initial_conditions_guess(2) = Uf0;
initial_conditions_guess(3) = Df0;
initial_conditions_guess(4) = Ef0;
initial_conditions_guess(5) = Ruf0;
initial_conditions_guess(6) = Rdf0;
initial_conditions_guess(7) = H0_0;
initial_conditions_guess(8) = U1_0;
initial_conditions_guess(9) = U2_0;
initial_conditions_guess(10) = U3_0;

% parameters_guess = [0.5; 0.082; 0.118; 0.03; 0.01; 0.5; 0.5; 0.082; 0.082; 0.082; 0.118; 0.118; 0.118; 0.03; 0.03; 0.03; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; population];
% parameters_guess = [0.5; 0.082; 0.118; 0.03; 0.01; 0.5; 0.5; 0.052; 0.052; 0.052; 0.2; 0.2; 0.2; 0.1; 0.1; 0.1; 0.1; 0.1; 0.1; 3; 3; 3; population];

parameters_guess = [params; population];

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

        for n = 1:Np-1
            if estimate_params(n)
                nlgr.Parameters(n).Minimum =0;
                if n == 11; nlgr.Parameters(n).Maximum = 10;else; nlgr.Parameters(n).Maximum = 1; end
            else
                nlgr.Parameters(n).Fixed = true;
            end
        end
        nlgr.Parameters(end).Fixed = true; %total population is not estimated

        W = eye(Ny);
        W(1,1) = weights(1);
        W(2,2) = weights(2);
        W(3,3) = weights(3);
        data_temp = data(i:i+identification_windows(d),:,:);
        opt = nlgreyestOptions('EstimateCovariance', false, 'OutputWeight', W);
%         opt.SearchMethod = 'fmincon';
        m = nlgreyest(data_temp, nlgr,opt);

        parameters_guess = zeros(1,Np);
        for n = 1:Np
            parameters_guess(n) = m.Parameters(n).Value;
        end
        
        x0 = zeros(Nx,1);
        for n = 1:Nx
            x0(n) = m.InitialStates(n).Value;
        end
        
        if d == length(update_days)
            [Time_temp, x_temp] = ode45(@(t,x) LD_SUDER(t,x, parameters_guess), [i, end_day], x0);
        else
            [Time_temp, x_temp] = ode45(@(t,x) LD_SUDER(t,x, parameters_guess), [i, update_days(d+1)], x0);
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

y = [x(3,:)+x(11,:)+x(12,:)+x(13,:); x(4,:)+x(14,:)+x(15,:)+x(16,:); x(6,:)+x(20,:)+x(21,:)+x(22,:)];

end