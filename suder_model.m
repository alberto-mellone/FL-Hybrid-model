function [dx, y] = suder_model(t,x,u,beta,rho,delta,sigma,theta, varargin)
%SUDER_MODEL 
% x = [S U D E Ru Rd]', y = [D E Rd]'
dx = [-beta*x(1)*x(2);
       (beta*x(1)*x(2) - (rho + delta)*x(2));
       (delta*x(2) - (sigma + theta)*x(3));
       theta*x(3);
       rho*x(2);
       sigma*x(3)];
y = [x(3); x(4); x(6)];

end

