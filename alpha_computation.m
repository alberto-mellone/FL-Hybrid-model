function [alpha0, alpha2, alpha3] = alpha_computation(S0, U0, alpha1, lambda)

Lambda = lambda*(U0/(S0 + U0));

lower = 1 -alpha1/2 - Lambda/2;
upper = 1 - 2/3*alpha1 - Lambda/3;
alpha0 = lower + (upper-lower)/10;
[alpha2, alpha3] = get_alpha2_3(alpha0,alpha1,Lambda);

end