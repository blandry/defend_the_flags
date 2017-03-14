% compare_algs.m    Compares all allocation functions on the exp cost
% matrix over a fixed number of attackers, defenders, and resources
close all;

batch_size = 10;

A_list = [2 2 4 4 4 8 8 8];
D_list = [2 3 2 4 6 4 6 7];
R_list = [5 5 5 5 5 5 5 5];

dspace = (A_list+1).^D_list;

N = length(A_list);

mean_t_exh = zeros(1,N);
mean_c_exh = zeros(1,N);
mean_t_bnb = zeros(1,N);
mean_c_bnb = zeros(1,N);
mean_t_passive = zeros(1,N);
mean_c_passive = zeros(1,N);
mean_t_market = zeros(1,N);
mean_c_market = zeros(1,N);
mean_t_rand = zeros(1,N);
mean_c_rand = zeros(1,N);

mean_total_cost = zeros(1,N);

bigwb = waitbar(0,'Total Progress');

for iter = 1:N
    A = A_list(iter);
    D = D_list(iter);
    R = R_list(iter);

    t_exh = zeros(1,batch_size);
    c_exh = zeros(1,batch_size);
    t_bnb = zeros(1,batch_size);
    c_bnb = zeros(1,batch_size);
    t_passive = zeros(1,batch_size);
    c_passive = zeros(1,batch_size);
    t_market = zeros(1,batch_size);
    c_market = zeros(1,batch_size);
    t_rand = zeros(1,batch_size);
    c_rand = zeros(1,batch_size);

    total_cost = zeros(1,batch_size);
    
    innerwb = waitbar(0,'Inner Loop');

    for n=1:batch_size
        % Intantiate players
        [a,d_fresh,r] = random_setup(A,D,R);
        total_cost(n) = sum([r.val]);

        % Compute probability matrix
        [IM,a,d] = intercept_matrix(a,d_fresh,r,0);
        P = compute_probs(IM,a,d);

        % Compute attacker/resource pairing matrix
        G = zeros(R,A);
        for j=1:A
            G(a(j).t,j) = 1;
        end

        % Evaluate Algorithms
%         %  - Exhuastive
%         tic
%         d = allocate_exhaustive(P,a,d_fresh,r);
%         M_exh = zeros(D,A);
%         for i=1:D
%             if d(i).a > 0 && d(i).a <= A
%                 M_exh(i,d(i).a) = 1;
%             end
%         end
%         t_exh(n) = toc;
%         c_exh(n) = exp_cost(M_exh,[r.val],P,[d_fresh.ca],G);

        %  - BranchAndBound
        tic
        d = allocate_bnb(P,a,d_fresh,r);
        M_bnb = zeros(D,A);
        for i=1:D
            if d(i).a > 0 && d(i).a <= A
                M_bnb(i,d(i).a) = 1;
            end
        end
        t_bnb(n) = toc;
        c_bnb(n) = exp_cost(M_bnb,[r.val],P,[d_fresh.ca],G);

    %     
    %     %  - Market
    %     tic
    %     d = allocate_market(P,a,d_fresh,r);
    %     M_market = zeros(D,A);
    %     for i=1:D
    %         if d(i).a > 0 && d(i).a <= A
    %             M_market(i,d(i).a) = 1;
    %         end
    %     end
    %     t_market(n) = toc;
    %     c_market(n) = exp_cost(M_market,[r.val],P,[d_fresh.ca],G);

        %  - Passive
        tic
        d = allocate_coord_descent(P,a,d_fresh,r);
        M_passive = zeros(D,A);
        for i=1:D
            if d(i).a > 0 && d(i).a <= A
                M_passive(i,d(i).a) = 1;
            end
        end
        t_passive(n) = toc;
        c_passive(n) = exp_cost(M_passive,[r.val],P,[d_fresh.ca],G);

        %  - Random
        tic
        d = allocate_rand(P,a,d_fresh,r);
        M_rand = zeros(D,A);
        for i=1:D
            if d(i).a > 0 && d(i).a <= A
                M_rand(i,d(i).a) = 1;
            end
        end
        t_rand(n) = toc;
        c_rand(n) = exp_cost(M_rand,[r.val],P,[d_fresh.ca],G);
        waitbar(n/batch_size,innerwb);
    end
    close(innerwb);
    
    mean_c_exh(iter) = mean(c_exh);
    mean_c_bnb(iter) = mean(c_bnb);
    mean_c_market(iter) = mean(c_market);
    mean_c_passive(iter) = mean(c_passive);
    mean_c_rand(iter) = mean(c_rand);
    
    mean_t_exh(iter) = mean(t_exh);
    mean_t_bnb(iter) = mean(t_bnb);
    mean_t_market(iter) = mean(t_market);
    mean_t_passive(iter) = mean(t_passive);
    mean_t_rand(iter) = mean(t_rand);
    
    mean_total_cost = mean(total_cost);
    
    waitbar(iter/N, bigwb);
end

close(bigwb)

%% Try harder examples

A_hard = [8 8 10 10 15];
D_hard = [8 9 9  10 13];
R_hard = [5 5 5 5 5];

dspace_hard = (A_hard+1).^(D_hard);

N = length(A_hard);
mean_t_passive_hard = zeros(1,N);
mean_c_passive_hard = zeros(1,N);
mean_t_market_hard = zeros(1,N);
mean_c_market_hard = zeros(1,N);
mean_t_rand_hard = zeros(1,N);
mean_c_rand_hard = zeros(1,N);

mean_total_cost_hard = zeros(1,N);

bigwb = waitbar(0,'Total Progress');

for iter = 1:N
    A = A_hard(iter);
    D = D_hard(iter);
    R = R_hard(iter);

    t_passive = zeros(1,batch_size);
    c_passive = zeros(1,batch_size);
    t_market = zeros(1,batch_size);
    c_market = zeros(1,batch_size);
    t_rand = zeros(1,batch_size);
    c_rand = zeros(1,batch_size);

    total_cost = zeros(1,batch_size);
    
    innerwb = waitbar(0,'Inner Loop');

    for n=1:batch_size
        % Intantiate players
        [a,d_fresh,r] = random_setup(A,D,R);
        total_cost(n) = sum([r.val]);

        % Compute probability matrix
        [IM,a,d] = intercept_matrix(a,d_fresh,r,0);
        P = compute_probs(IM,a,d);

        % Compute attacker/resource pairing matrix
        G = zeros(R,A);
        for j=1:A
            G(a(j).t,j) = 1;
        end

        % Evaluate Algorithms

    %     
    %     %  - Market
    %     tic
    %     d = allocate_market(P,a,d_fresh,r);
    %     M_market = zeros(D,A);
    %     for i=1:D
    %         if d(i).a > 0 && d(i).a <= A
    %             M_market(i,d(i).a) = 1;
    %         end
    %     end
    %     t_market(n) = toc;
    %     c_market(n) = exp_cost(M_market,[r.val],P,[d_fresh.ca],G);

        %  - Passive
        tic
        d = allocate_coord_descent(P,a,d_fresh,r);
        M_passive = zeros(D,A);
        for i=1:D
            if d(i).a > 0 && d(i).a <= A
                M_passive(i,d(i).a) = 1;
            end
        end
        t_passive(n) = toc;
        c_passive(n) = exp_cost(M_passive,[r.val],P,[d_fresh.ca],G);

        %  - Random
        tic
        d = allocate_rand(P,a,d_fresh,r);
        M_rand = zeros(D,A);
        for i=1:D
            if d(i).a > 0 && d(i).a <= A
                M_rand(i,d(i).a) = 1;
            end
        end
        t_rand(n) = toc;
        c_rand(n) = exp_cost(M_rand,[r.val],P,[d_fresh.ca],G);
        waitbar(n/batch_size,innerwb);
    end
    close(innerwb);
    
    mean_c_market_hard(iter) = mean(c_market);
    mean_c_passive_hard(iter) = mean(c_passive);
    mean_c_rand_hard(iter) = mean(c_rand);
   
    mean_t_market_hard(iter) = mean(t_market);
    mean_t_passive_hard(iter) = mean(t_passive);
    mean_t_rand_hard(iter) = mean(t_rand);
    
    mean_total_cost_hard = mean(total_cost);
    
    waitbar(iter/N, bigwb);
end

close(bigwb)

%%

subplot(1,2,1)
semilogx(dspace,real((mean_c_bnb-mean_c_bnb))./mean_total_cost, '*');
hold on
semilogx(dspace,real((mean_c_passive-mean_c_bnb))./mean_total_cost, '*');
semilogx(dspace,real((mean_c_market-mean_c_bnb))./mean_total_cost, '*');
semilogx(dspace,real((mean_c_rand-mean_c_bnb))./mean_total_cost, '*');
legend('Branch & Bound','Passive Coordination','Market','Random Allocation');
title('Error from Optimal Cost Solution')
ylabel('Error relative to Total Resource Value')
xlabel('Problem Size ( (A+1)^D )');
grid on

subplot(1,2,2)
loglog(dspace, mean_t_bnb, '*')
hold on
loglog([dspace dspace_hard], [mean_t_passive mean_t_passive_hard], '*')
loglog([dspace dspace_hard], [mean_t_market mean_t_market_hard], '*')
loglog([dspace dspace_hard], [mean_t_rand mean_t_rand_hard], '*')
loglog(dspace, 1e-4*dspace,'--k')
loglog([dspace dspace_hard], 0.5e-4*[A_list A_hard].*[D_list D_hard],'-.k')
loglog([dspace dspace_hard], 1.6e-5*[D_list D_hard],':k')

legend('Branch & Bound', 'Passive Coordination', 'Market','Random Allocation', 'O((A+1)^D)', 'O(AD)', 'O(D)');
title('Execution Time vs Problem Size');
ylabel('Avg Execution Time (s)');
xlabel('Problem Size ( (A+1)^D )');
grid on