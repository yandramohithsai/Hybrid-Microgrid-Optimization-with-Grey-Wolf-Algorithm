function [LPSP,DPSP,COE,price_electricity,renewable_factor,reliability,Edump,b] = economicanalysis2(p_npv,ad,houses,nwt,nPdg)
%% Load Input
load('Vellore_VIT.csv');
windspeed = Vellore_VIT(:,1); %hourly
temperature = Vellore_VIT(:,2); %hourly
solarradiation = Vellore_VIT(:,3)/1000; 
clear Vellore_VIT
%Power calculation
%% Solar power
%tamb = (5/9)*(temperature-32);
tamb = temperature;
g = solarradiation;
gref = 1; %1000W/m^2
tref = 25; %temperature at reference condition
alpha = -3.7e-3; %temperature coefficient
tc = tamb+(0.0256).*g; %PV cell temperature
fpv = 0.986; % PV de-rating factor
Ppv = fpv*(p_npv.*(g/gref)).*(1+alpha.*(tc-tref)); %PV output power
clear tc
clear tamb
clear g
for t = 1:1:8640
    if Ppv(t) > p_npv
        Ppv(t) = p_npv;
    end
end
%% Battery
load1 = [1.5 1 0.5 0.5 1 2 2 2.5 2.5 3 3 5 4.4 4 3.43 3 1.91 2.48 3 3 3.42 3.44 2.51 2]; % load profile Kw
load1 = load1/5; 
load1 = load1*2;
%houses=1;%number of houses
load2 = houses.*load1;
%Hourly load data for one year
a = 0;
for i = 1:1:360
    a = [a,load2];
end
a(1)=[];
Pl=a;
%ad=3; %daily autonomy
uinv = 0.95;
ub = 0.85;
DOD = 0.7;
el = mean(load2);
cwh = (el*ad)/(uinv*ub*DOD);%storage capacity for battery
%% Wind turbine
uw = 0.95;
vco = 25; %cut out speed
vci = 2.5; %cut In speed 
vr = 8; %rated speed(m/s)
pr = 1; %rated power(kW)
v1 = windspeed;
beta = 0.25;
href = 10;
h = 25;
v2 = ((h/href)^(beta))*v1;
for t = 1:1:8640
    if v2(t) < vci && v2(t) > vco
        Pwtg(t) = 0;
    elseif vci <= v2(t) && v2(t) < vr
        Pwtg(t) = (pr/(vr^3-vci^3))*(v2(t))^3-(vci^3/(vr^3-vci^3))*(pr);
    elseif vr <= v2(t) && v2(t) < vco
        Pwtg(t) = pr;
    else 
        Pwtg(t) = 0;
    end
    Pw(t) = Pwtg(t)*uw*nwt; %electric power from wind turbine
end
%% Diesel generator
Pdg = 4; 
Pdg = nPdg*Pdg; %kW output power of diesel generator
Bg = 0.08145;
Ag = 0.246;
Pr = 4;
Pr = nPdg*Pr; %nominal power kW
Fg = Bg*Pr+Ag*Pdg; %fuel consumption of the diesel generator
%% System operation
contribution = zeros(5,8640);%pv,wind, battery, diesel contribution in each hour
Ebmax = cwh;
Ebmin = cwh*(1-DOD);
SOCb = 0.2;
Eb = zeros(1,8640);
time = zeros(1,8640);
diesel = zeros(1,8640);
Ech = zeros(1,8640);
Edch = zeros(1,8640);
Edump = zeros(1,8640);
Eb(1,1) = SOCb*Ebmax; %Energy stored in the battery

for t = 2:1:8640
    if Pw(t) + Ppv(t) >= (Pl(t)/uinv)

        if Pw(t) + Ppv(t) > (Pl(t)/uinv)

            Pch(t) = (Pw(t)+Ppv(t))-(Pl(t)/uinv);
            Ech(t) = Pch(t);

            if Ech(t) <= Ebmax-Eb(t)
                Eb(t) = Eb(t-1)+Ech(t);

                if Eb(t) > Ebmax
                    Eb(t) = Ebmax;
                    Edump(t) = Ech(t)-(Ebmax-Eb(t));
                else
                    Edump(t) = 0;
                end
                
            else
                Eb(t) = Ebmax;
                Edump(t) = Ech(t)-(Ebmax-Eb(t));                
            end            
            
            time(t)=1;
            contribution(1,t) = Ppv(t);
            contribution(2,t) = Pw(t);
            contribution(3,t) = Edch(t);
            contribution(4,t) = diesel(t);
            contribution(5,t) = Edump(t);

    else
        Eb(t) = Eb(t-1);        
        end
    else
        Pdch(t) = (Pl(t)/uinv)-(Pw(t)+Ppv(t));
        Edch(t) = Pdch(t);

        if(Eb(t-1)-Ebmin) >= (Edch(t))
            Eb(t) = Eb(t-1)-Edch(t);
            time(t) = 2;
        else
            Eb(t)=Eb(t-1)+(Pr*uinv+Pw(t)+Ppv(t)-((Pl(t)/uinv)*1));
            if Eb(t)>Ebmax
                Edump(t)=Eb(t)-Ebmax;
                Eb(t)=Ebmax;
            end
            if Eb(t)<Ebmin
                Edump(t)=0;
                Eb(t)=Ebmin;
            end
            diesel(t)=Pr*uinv;
        end

            contribution(1,t)=Ppv(t);
            contribution(2,t)=Pw(t);
            contribution(3,t)=Edch(t);
            contribution(4,t)=diesel(t);
            contribution(5,t)=Pl(t);
    end
end
%% Initialization
%Initial Cost
WT_C = 2000;
PV_C = 3500;
BAT_C = 280;
DSL_C = 1000;
INV_C = 2500;
PV_reg = 1500;
Wind_reg = 1000;

%Economic index
Realinterest = 12;

%Life time
%WT_LF = 24;
%PV_LF = 24;
%INV_LF = 24;
BAT_LF = 12;
DSL_LF = 24000;
PRJ_LF = 24;

%Running cost
OM = 20;

%Rated power
WT_P = 2;
PV_P = p_npv;
BAT_P = cwh;
DSL_P = 4;
%% Economic analysis
a = contribution';
b = sum(a);
%renewable_factor = (1-(b(4)/(b(1)+b(2))));
renewable_factor = (b(4)/(b(1)+b(2)));

k=0;
total_loss = 0;
aa = zeros(1,8640);
for t = 1:1:8640
    if Pl(t) > (Ppv(t)+Pw(t)+(Eb(t)-Ebmin)+diesel(t))
       total_loss = total_loss+(Pl(t)-(Ppv(t)+Pw(t)+(Eb(t)-Ebmin)+diesel(t)));
       aa(t) = Pl(t)-Ppv(t)-Pw(t)+Eb(t)+diesel(t);
       k=k+1;
    end
end

reliability = k/8640;
[i,j,k] = find(diesel);
k = sum(k/4);
fuel_consumption = Fg*k;
k = DSL_LF/k;
if k < PRJ_LF
     n = floor(PRJ_LF/k);
     price_d = DSL_C*DSL_P*n; 
else
     price_d = DSL_C*DSL_P;
end

k = floor(PRJ_LF/BAT_LF);
price_b = BAT_C*BAT_P*k;

i = Realinterest/100;
initial_cost = WT_C*WT_P*nwt+PV_C*PV_P+price_b+price_d+INV_C+PV_reg+Wind_reg;
OM = initial_cost*(OM/100);
initial_cost = initial_cost+OM;
CRF = (i*(1+i)^PRJ_LF)/(((1+i)^PRJ_LF)-1);
Anual_cost = initial_cost*CRF;
Anual_cost_fuel = fuel_consumption*PRJ_LF*CRF;
Anual_cost = Anual_cost+Anual_cost_fuel;
Anual_load = sum(Pl);

price_electricity = Anual_cost/Anual_load;
LPSP = total_loss/(sum(Pl));
DPSP = sum(aa)/sum(Pl);
COE = Anual_cost/Anual_load*CRF;
Edump = sum(Edump);

 end