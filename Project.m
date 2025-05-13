clc;
clear all;
close all;

SearchAgents_no = 5; % Number of search agents
Max_iteration = 20; % Maximum number of iterations
lb = [0 0 1 0 0];
ub = [45 6 20 10 4];
dim = 5;


SearchAgents.LPSP = [];
SearchAgents.COE = [];
SearchAgents.fitness = [];
SearchAgents  = repmat(SearchAgents,1,SearchAgents_no);

Alpha_pos = zeros(1,dim);
Alpha_score = inf;

Beta_pos = zeros(1,dim);
Beta_score = inf;

Delta_pos = zeros(1,dim);
Delta_score = inf;

%Initialize the positions of search agents
Boundary_no = size(ub,2); % numnber of boundaries

if Boundary_no==1
    Positions = rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

if Boundary_no>1
    for i=1:dim
        ub_i=ub(i);
        lb_i=lb(i);
        Positions(:,i) = rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
end

Convergence_curve=zeros(Max_iteration,2);

l=0;% Loop counter
% Main loop
while l<Max_iteration
    for i=1:size(Positions,1)

        % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub = Positions(i,:)>ub;
        Flag4lb = Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;

        % Calculate objective function for each search agent
        p_npv = Positions(i,1);
        ad = round(Positions(i,2));
        houses = round(Positions(i,3));
        nwt = round(Positions(i,4));
        nPdg = round(Positions(i,5));

        [LPSP,DPSP,COE,price_electricity,renewable_factor,reliability,Edump,b] = economicanalysis2(p_npv,ad,houses,nwt,nPdg);
        
        SearchAgents(i).LPSP = LPSP;
        SearchAgents(i).COE = COE;
        SearchAgents(i).fitness  = [LPSP,COE];

            % Update Alpha, Beta, and Delta
            if all(SearchAgents(i).fitness < Alpha_score)
                Alpha_score = SearchAgents(i).fitness; % Update alpha
                Alpha_pos = Positions(i,:);
            end

            if all(SearchAgents(i).fitness > Alpha_score) && all(SearchAgents(i).fitness < Beta_score) 
                Beta_score = SearchAgents(i).fitness; % Update beta
                Beta_pos = Positions(i,:);
            end

            if all(SearchAgents(i).fitness > Alpha_score) && all(SearchAgents(i).fitness > Beta_score) && all(SearchAgents(i).fitness < Delta_score) 
                Delta_score = SearchAgents(i).fitness; % Update delta
                Delta_pos = Positions(i,:);
            end
    end
    
    
    a=2-l*((2)/Max_iteration); % a decreases linearly fron 2 to 0

    % Update the Position of search agents including omegas
    for i=1:size(Positions,1)
        for j=1:size(Positions,2)

            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]

            A1=2*a*r1-a;
            C1=2*r2;

            D_alpha = abs(C1*Alpha_pos(j)-Positions(i,j));
            X1 = Alpha_pos(j)-A1*D_alpha;

            r1=rand();
            r2=rand();

            A2=2*a*r1-a;
            C2=2*r2;

            D_beta = abs(C2*Beta_pos(j)-Positions(i,j));
            X2 = Beta_pos(j)-A2*D_beta;

            r1=rand();
            r2=rand();

            A3=2*a*r1-a;
            C3=2*r2;

            D_delta = abs(C3*Delta_pos(j)-Positions(i,j));
            X3 = Delta_pos(j)-A3*D_delta;

            Positions(i,j)=(X1+X2+X3)/3;

        end
    end

    l=l+1;
    Convergence_curve(l,:) = Alpha_score;
    disp(['Iteration',num2str(l), ': Best Cost =',num2str(Convergence_curve(l,:))]);
end

figure(1)
plot(Convergence_curve(:,1),'Color','r') 
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far : LPSP');

figure(2)
plot(Convergence_curve(:,2),'Color','b') 
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far : COE');

 display(['The best solution obtained by GWO is : ', num2str(Alpha_pos)]);
 display(['The best optimal value of the objective funciton is : ', num2str(Alpha_score)]);
