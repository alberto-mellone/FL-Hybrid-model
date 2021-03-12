function [dx,y] = lockdown_model(t,x,u,beta,rho,delta,sigma,theta, beta_H,rho_H,delta_H,sigma_H,theta_H,beta_FH,T, varargin)
%LOCKDOWN_MODEL

% x = [Sf Uf Df Ef Ruf Rdf x(1-6)
%      H0   x(7)
%      U1 U2 U3 x(8-10)
%      D1 D2 D3 x(11-13)
%      E1 E2 E3 x(14-16)
%      Ru1 Ru2 Ru3 x(17-19)
%      Rd1 Rd2 Rd3] x(20-22)
% y = [Df+D1+D2+D3  Ef+E1+E2+E3   Rdf+Rd1+Rd2+Rd3]

dx = [...%free variables
      -beta*x(1)*x(2);
      (beta*x(1)*x(2) - (rho + delta)*x(2));
      (delta*x(2) - (sigma + theta)*x(3));
      theta*x(3);
      rho*x(2);
      sigma*x(3);
      %H0
      -beta_FH*x(2)*x(7);
      %U1 U2 U3  
      -beta_H*x(8) - (rho_H+delta_H)*x(8) + beta_FH*x(2)*x(7)/T - beta_FH*(2/3)*x(2)*x(8);
      2*beta_H*x(8) - 2*beta_H*x(9) - (rho_H/2+delta_H*2)*x(9) + (4/3)*beta_FH*x(2)*x(8) - (1/3)*beta_FH*x(2)*x(9);
      3*beta_H*x(9) - (rho_H/3+delta_H*3)*x(10) + (1/2)*beta_FH*x(2)*x(9);
      %D1 D2 D3   
      delta_H*x(8) - (sigma_H+theta_H)*x(11);
      2*delta_H*x(9) - (1/2)*(sigma_H+theta_H)*x(12);
      3*delta_H*x(10) - (1/3)*(sigma_H+theta_H)*x(13);
      %E1 E2 E3
      theta_H*x(11);
      (1/2)*theta_H*x(12);
      (1/3)*theta_H*x(13);
      %Ru1 Ru2 Ru3
      rho_H*x(8);
      (1/2)*rho_H*x(9);
      (1/3)*rho_H*x(10);
      %Rd1 Rd2 Rd3
      sigma_H*x(11);
      (1/2)*sigma_H*x(12);
      (1/3)*sigma_H*x(13)];


y = [x(3)+x(11)+x(12)+x(13), x(4)+x(14)+x(15)+x(16), x(6)+x(20)+x(21)+x(22)]';
end

