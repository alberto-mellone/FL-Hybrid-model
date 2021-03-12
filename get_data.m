function data = get_data(csv_file, population)
    
country=csvread(csv_file);
s_country=length(country);

D_measured = zeros(1, s_country);
E_measured = zeros(1, s_country);
Rd_measured = zeros(1, s_country);

sampling_time = 1; %day is the unit of measure

for i=1:s_country
   D_measured(i)=country(i,1)/population; 
   Rd_measured(i)=country(i,2)/population;
   E_measured(i)=country(i,3)/population;
end
y_measured = [D_measured; E_measured; Rd_measured];
data = iddata(y_measured', [], sampling_time);

end