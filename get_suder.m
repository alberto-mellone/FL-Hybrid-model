function y = get_suder(x)
%GET_SUDER 

% x = [Sf Uf Df Ef Ruf Rdf x(1-6)
%      H0   x(7)
%      U1 U2 U3 x(8-10)
%      D1 D2 D3 x(11-13)
%      E1 E2 E3 x(14-16)
%      Ru1 Ru2 Ru3 x(17-19)
%      Rd1 Rd2 Rd3] x(20-22)

U = x(2,:) + x(8,:) + x(9,:) + x(10,:);
D = x(3,:) + x(11,:) + x(12,:) + x(13,:);
E = x(4,:) + x(14,:) + x(15,:) + x(16,:);
Ru = x(5,:) + x(17,:) + x(18,:) + x(19,:);
Rd = x(6,:) + x(20,:) + x(21,:) + x(22,:);
S = ones(1, length(U)) - U - D - E - Ru - Rd;
y = [S; U; D; E; Ru; Rd];
end

