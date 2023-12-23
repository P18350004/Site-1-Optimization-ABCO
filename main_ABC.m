clc
clear all

%% Problem settings
lb = [0 0 0 0 0 0 80 100 100 100 100 100];      %lower search space of soil layer thickness and their shear wave velocity (Vs)
ub = [4  4 5 6 9 19 150 250 250 450 450 450];   % Upper search space of soil layer thickness and their Vs         

prob = @Fitness_misfit;                          %fitness function

%% Algorithm Parameters
Np = 200;   % Number of iteraation samples
T = 100 ;   % Number of iternations 
limit = 20;   %% Song 2015 (5 D^2)

%% starting of ABC
f = NaN(Np,1);
fit = NaN(Np,1);
trial = zeros(Np,1);
BestFitIter = NaN(T+1,1);   

D = length(lb);

P = repmat(lb,Np,1) + repmat((ub-lb),Np,1).*rand(Np,D);

for p =1:Np
    f(p) = prob(P(p,:));
    fit(p) = CalFit(f(p));
end

[bestobj,ind] = min(f);
bestsol = P(ind,:);

for t = 1:T
    
    %% Employed Bee Phase
    for i =1:Np
%       n=i;
    [trial,fit,P,f] = GenNewSol(prob, lb , ub , Np, i , P, fit , trial ,f ,D);
    end
    
    %% onlooker Bee Phase
probability = 0.9*(fit/max(fit))+0.1;   %% 0.9 &0.1 and 0.7& 0.3   

m=0; n=1;
  while(m < Np)
    if(rand < probability(n))
        [trial,fit,P,f] = GenNewSol(prob, lb , ub , Np, n , P, fit , trial ,f ,D);
        m = m+1;
    end
    n = mod(n,Np) + 1;
end

[bestobj,ind] = min([f;bestobj]);
Combinedsol = [P;bestsol];
bestsol = Combinedsol(ind,:);

%% Scout Phase
[val,ind] = max(trial);

if(val > limit)
    trial(ind) = 0;
    P(ind,:) = lb + (ub-lb).*rand(1,D);
    f(ind) = prob(P(ind,:));
    fit(ind) = CalFit(f(ind));
end

 BestFitIter(t+1) = min(f);
    disp(['Iteration' num2str(t) ': Best Fitness =' num2str(BestFitIter(t+1))])
end

[bestobj,ind] = min([f;bestobj]);
Combinedsol = [P;bestsol];
bestsol = Combinedsol(ind,:);

plot(0:T, BestFitIter);
xlabel('Iterations');
ylabel('Best Fitness Value');
title('Ant Bee Colony Optimisation');
set(gca,'Fontsize',16,'Fontname','Times New Roman');
set(gcf,'units','centimeters')
% pos = [2, 2, FigWidth, FigHeight]; 
% set(gcf,'Position',pos)
save Result
