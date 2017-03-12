function [attackers, defenders, t, r, cost_func] = simulator(a,d,r,realloc_period,alg)
% Run the simulation
%   Inputs; a,d,r structs containing values
%           realloc_period: 0 for no realloc, Inf for realloc every event,
%                           else the actual reallocation period value.
realloc_on_event = 1;
if realloc_period == 0
    realloc_period = Inf;
    realloc_on_event = 0;
end


% Begin simulation
A = length(a);
D = length(d);
R = length(r);

% Arrays to hold trajectories
t = [0];
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

% To compute allocation, need to compute interception for all defenders
IM = repmat(struct('vdhat',0,'vahat',0,'t_reach',0,'t_int',0,'t_rem',0,'flag',0), D, A);

% Run Simulation
while sum([a.active]) > 0
    % Compute intercept information for all defender attacker pairs
    for i=1:D
        for j=1:A
            xd = [d(i).x,d(i).y];
            xa = [a(j).x,a(j).y];
            xr = [r(a(j).t).x,r(a(j).t).y];

            % Compute intercept point for d_i and a_j
            [vdhat,vahat,t_reach,t_int,t_loss,success] = intercept(xd,d(i).V,xa,a(j).V,xr,d(i).R);
            IM(i,j).vdhat = vdhat;
            IM(i,j).vahat = vahat;
            IM(i,j).t_reach = t_reach + t(end); % Add to current time
            IM(i,j).t_int = t_int + t(end); % Add to current time
            IM(i,j).t_rem = max(0,t_loss - t_reach); % How long defender has after reaching attacker
            IM(i,j).flag = success;
            
            if xd(1) == xa(1) && xd(2) == xa(2) % already intercepted
                IM(i,j).flag = 1;
                IM(i,j).t_int = t(end);
                IM(i,j).vdhat = vahat;
            end

            % Record the time that attacker will hit its target
            a(j).t_destroy = t_loss + t(end);
        end
    end
    
    % Log current defender allocation
    d_old = [d.a];
    
    % Remove attackers that are not active from allocation
    [IM_active, a_active, map] = parse_active_attackers(IM, a);
    
    % Computing the intercept probabilities
    P = compute_probs(IM_active,a_active,d);
    
    % Using the intercept matrix IM give each defender an attacker
    if strcmp(alg,'exhaustive')
        d = allocate_exhaustive(IM_active,P,a_active,d,r);
    elseif strcmp(alg, 'coord')
        d = allocate_coord_descent(IM_active,P,a_active,d,r);
    else
        fprintf('Can"t think of an allocation');
    end
    %d = allocate_discrete_search(IM,P,a,d,r);
    %d = allocate_market(IM,P,a,d,r);
    
    
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
    %disp([d.a])
    
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
                    r(targ).damage = r(targ).damage + r(targ).val; % Target damaged
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
        
        cost_func = [cost_func; exp_cost(M,[r.val],P,[d.ca],G)];
        if isnan(cost_func(end))
            hey;
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

