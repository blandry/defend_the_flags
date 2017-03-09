function [attackers, defenders] = simulator(a,d,r)
% Run the simulation
%   Inputs; a,d,r structs containing values

% Begin simulation
A = length(a);
D = length(d);
R = length(r);

% Arrays to hold trajectories
t = [0];
defenders = cell(1,D);
attackers = cell(1,A);
Nleft = A;
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
while Nleft > 0
    % Compute allocation M
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
            IM(i,j).t_rem = t_loss - t_reach; % How long defender has after reaching attacker
            IM(i,j).flag = success;

            % Record the time that attacker will hit its target
            a(j).t_destroy = t_loss + t(end);
        end
    end

    % Computing the intercept probabilities
    P = compute_probs(IM,a,d);
    % Using the intercept matrix IM give each defender an attacker
    d = allocate_exhaustive(IM,P,a,d,r);
    %d = allocate_discrete_search(IM,P,a,d,r);
    %d = allocate_market(IM,P,a,d,r);
    
    % All below would be done in allocate function
    for i=1:D
        d(i).vdhat = IM(i,d(i).a).vdhat;
        d(i).t_reach = IM(i,d(i).a).t_reach;
        d(i).t_int = IM(i,d(i).a).t_int;
    end

    for j=1:A
        a(j).vahat = IM(1,j).vahat;
    end
    
    % Begin one allocation period
    dt = .1;
    no_event = 1;
    while no_event
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
                    Nleft = Nleft - 1;
                    no_event = 0;
                end
            end
            attackers{j} = [attackers{j}; [a(j).x, a(j).y]];
        end

        % Update position of defenders and check for intercepts and attack
        for i=1:D
            if interaction(i) == 1 % The defender is following the attacker
                d(i).x = a(i).x;
                d(i).y = a(i).y;
            else
                d(i).x = d(i).x + d(i).V*d(i).vdhat(1)*dt;
                d(i).y = d(i).y + d(i).V*d(i).vdhat(2)*dt;
            end
            defenders{i} = [defenders{i}; [d(i).x, d(i).y]];

            % Update interaction array if needed
            if d(i).t_reach <= t(end) % defender reached allocated attacker
                if interaction(i) == 0 % they werent interacting last time
                    % deploynet(args);
                    flag = 1; % pretend it won
                    interaction(i) = 1;
                else
                    % attempt_collision(args);
                end

                % If one the attacks was successful
                if flag == 1
                    a(d(i).a).active = 0;
                    Nleft = Nleft - 1;
                    no_event = 0; % Reallocate
                end
                d(i).t_reach = d(i).t_reach + 5; % Next time they can attack
            end
        end

        if Nleft > 0
            t = [t; t(end)+dt];
        end
    end
end

end
