function fx = SUDER(t,x,params)

beta = params(1);
rho = params(2);
delta = params(3);
sigma = params(4);
theta = params(5);

fx = [...%free variables
      -beta*x(1)*x(2);
      (beta*x(1)*x(2) - (rho + delta)*x(2));
      (delta*x(2) - (sigma + theta)*x(3));
      theta*x(3);
      rho*x(2);
      sigma*x(3)];

end