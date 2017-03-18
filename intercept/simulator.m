function [attackers, defenders, t, r, cost_func, damage] = simulator(a,d,r,realloc_period,alg,dtype,cfunc)
% Run the simulation
%   Inputs; a,d,r structs containing values
%           realloc_period: 0 for no realloc, Inf for realloc every event,
%                           else the actual reallocation period value.
realloc_on_event = 1;
if realloc_period == 0
    realloc_period = 100000;
    realloc_on_event = 0;
elseif realloc_period == Inf
    realloc_period = 100000;
end


% Begin simulation
A = length(a);
D = length(d);
R = length(r);

% Arrays to hold trajectories
t = [0];
damage = [0];
defenders = cell(1,D);
attackers = cell(1,A);
cost_func = [sum([r.val])];

for i=1:D
    defenders{i} = [d(i).x, d(i).y];
end
for j=1:A
    attackers{j} = [a(j).x, a(j).y];
end

% Initialize interaction array
interaction = zeros(1,D);

% Run Simulation
dam = 0;
while sum([a.active]) > 0
    % Compute intercept information for all defender attacker pairs
    [IM,a,d] = intercept_matrix(a,d,r,t(end));
    
    % Log current defender allocation
    d_old = [d.a];
    
    % Remove attackers that are not active from allocation
    [IM_active, a_active, map] = parse_active_attackers(IM, a);
    
    % Computing the intercept probabilities
    P = compute_probs(IM_active,a_active,d);
    
    % Using the intercept matrix IM give each defender an attacker
    if strcmp(alg,'exhaustive')
        d = allocate_exhaustive(P,a_active,d,r);
    elseif strcmp(alg, 'coord')
        d = allocate_coord_descent(P,a_active,d,r,cfunc);
    elseif strcmp(alg, 'market')
        d = market(P,a_active,d,r,1);
    elseif strcmp(alg, 'bnb')
        d = allocate_bnb(P,a_active,d,r,cfunc);
    else
        fprintf('Can"t think of an allocation');
    end
    
    % Fix the map to attacker from allocation
    current = [d.a];
    for j=1:numel(map)
        switches = find(current==j); % gives which defenders need d.a mapped from j to map(j)
        if ~isempty(switches)
            for i=1:numel(switches)
                d(switches(i)).a = map(j);
            end
        end
    end
    
    % Set proper policy for each defender given the attacker they are
    % paired to
    for i=1:D
        if d(i).a == 0 % A defender was not paired to an attacker
            home = [0,0];
            d(i) = goto(d(i),home,t(end));
        else
            d(i).vdhat = IM(i,d(i).a).vdhat;
            d(i).t_reach = IM(i,d(i).a).t_reach;
            d(i).t_int = IM(i,d(i).a).t_int;
        end
        
        % Compare old allocation to new to update interaction vector
        if d_old(i) ~= d(i).a
            interaction(i) = 0;
        end
    end

    for j=1:A
        a(j).vahat = IM(1,j).vahat;
    end
    
    % Begin one allocation period
    dt = .1;
    no_event = 1;
    for z=1:dt:realloc_period
        % Update positions of attackers and check for target hits
        for j=1:A
            % Update if attacker alive and not at target yet
            if a(j).active == 1
                if a(j).t_destroy >= t(end)
                    a(j).x = a(j).x + a(j).V*a(j).vahat(1)*dt;
                    a(j).y = a(j).y + a(j).V*a(j).vahat(2)*dt;
                else
                    targ = a(j).t;
                    if strcmp(dtype, 'Total')
                        if r(targ).damage == 0 % Its hasn't been hit yet
                            r(targ).damage = r(targ).damage + r(targ).val; % Target damaged
                            dam = dam + r(targ).val;
                        end
                    elseif strcmp(dtype, 'Incremental')
                        r(targ).damage = r(targ).damage + r(targ).val; % Target damaged
                        dam = dam + r(targ).val;
                    end
                    a(j).active = 0; % Attacker gone
                    no_event = 0; % Reallocate
                end
            end
            attackers{j} = [attackers{j}; [a(j).x, a(j).y]];
        end

        % Update position of defenders and check for intercepts and attack
        for i=1:D
            if d(i).a == 0 % A defender was not paired to an attacker
                if d(i).t_int > t(end) % Note home yet
                    d(i).x = d(i).x + d(i).V*d(i).vdhat(1)*dt;
                    d(i).y = d(i).y + d(i).V*d(i).vdhat(2)*dt;
                end
            else
                if d(i).t_int <= t(end) && a(d(i).a).active == 1 % The defender is following the active attacker
                    d(i).x = a(d(i).a).x;
                    d(i).y = a(d(i).a).y;
                elseif a(d(i).a).active == 1
                    d(i).x = d(i).x + d(i).V*d(i).vdhat(1)*dt;
                    d(i).y = d(i).y + d(i).V*d(i).vdhat(2)*dt;
                end
                % Update interaction array if needed
                if d(i).t_reach <= t(end) && a(d(i).a).active == 1 % defender reached allocated attacker
                    if interaction(i) == 0 % they werent interacting last time
                        p = attack(d(i),a(d(i).a),1);
                        interaction(i) = 1;
                    else
                        p = attack(d(i),a(d(i).a),0);
                    end

                    % Evaluate if successful
                    rng('shuffle');
                    val = rand(1);
                    if val < p
                        a(d(i).a).active = 0;
                        no_event = 0; % Reallocate
                        %fprintf(1,'D %d kills A %d \n',i,d(i).a);
                    end            
                    d(i).t_reach = d(i).t_reach + 5; % Next time they can attack
                end
            end
            defenders{i} = [defenders{i}; [d(i).x, d(i).y]];
        end

        t = [t; t(end)+dt];
        damage = [damage; dam];
        
        M = zeros(D,numel(a_active));
        for i=1:D
            if d(i).a > 0 && d(i).a <= numel(a_active)
                M(i,d(i).a) = 1;
            end
        end
        
        % attacker/target pairs
        G = zeros(R,numel(a_active));
        for j=1:numel(a_active)
            G(a(j).t,j) = 1;
        end
        
        cost_func = [cost_func; real(exp_cost(M,[r.val],P,[d.ca],G,cfunc))];
        if isnan(cost_func(end))
            disp('hey');
        end
        if sum([a.active]) == 0
            break; % All attackers are inactive
        end
        
        if ~no_event && realloc_on_event
            break
        end
    end
end

end

