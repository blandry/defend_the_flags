function [d] = market(P,a,d,r,enable)
% Market based algorithm, with optional subcontracting rounds
%   P is matrix of probabilities, a, d ,r are the struct arrays
%   enable is set to 1 if you want to enable subcontracting mode

A = numel(a);
D = numel(d);
R = numel(r);

% Initial Contract Round
% Determine what the defenders want
ds = repmat(struct('bids',[],'profits',[],'order',[],'choice',0,...
    'award',[],'a',[],'swprofit',0,'cprofit',0), 1, D);
as = repmat(struct('award',[],'buyers',[],'req',[]), 1, A);
market = struct('as',ones(1,A),'ds',ones(1,D));
for i=1:D
    for j=1:A
        ds(i).bids(j) = r(a(j).t).val*(1 - P(i,j));
        ds(i).profits(j) = r(a(j).t).val - ds(i).bids(j);
    end
    % Now create the order vector that stores the defenders order
    % preference in choosing attackers
    tosort = [ds(i).profits; 1:A];
    [Y,I] = sort(tosort(1,:),'descend');
    ds(i).order = tosort(2,I);
    
    % Choose the one that gives best profit
    ds(i).choice = ds(i).order(1);   
end

losers = zeros(1,numel(ds));
while sum(market.as) > 0 && sum(market.ds) > 0
    % Update the buyer list for each attacker by adding all buyers still left
    % in market
    dleft = find(market.ds==1);
    aleft = find(market.as==1);
    for k=1:numel(aleft)
        j = aleft(k);
        as(j).buyers = [];
    end
    
    % Update losing defender choice and add to attackers buyer list
    for k=1:numel(dleft)
        i = dleft(k);
        % Check if it was a loser last time
        if losers(i) == 1 % Then i is a loser from the last round
            % Find the highest priority attacker that is still on market
            for j=1:A
                if ~isempty(find(aleft==ds(i).order(j),1)) % If j on the market
                    ds(i).choice = ds(i).order(j);
                    market.ds(i) = 1;
                    break
                else
                    ds(i).choice = 0;
                    ds(i).award = 0;
                    market.ds(i) = 0;
                end
            end
        end
        % If the choice was able to be set
        if ds(i).choice ~= 0
            as(ds(i).choice).buyers = [as(ds(i).choice).buyers, i];
        end
    end

    % Award contracts for attackers left in market to the lowest bidder
    losers = zeros(1,numel(ds));
    for k=1:numel(aleft)
        j = aleft(k);
        buyers = as(j).buyers;
        if ~isempty(buyers) % If the attacker has buyers
            lowbidder = buyers(1);
            for k=1:numel(buyers)
                b = buyers(k);
                if ds(b).bids(j) < ds(lowbidder).bids(j)
                    lowbidder = b;
                end
            end
            % Check to make sure the lowest bidder is doesnt have zero
            % probability
            if P(lowbidder,j) ~= 0
                as(j).award = [lowbidder]; % Mark that award went to lowbidder
                ds(lowbidder).award = j; % Mark that lowbidder got j
                ds(lowbidder).cprofit = ds(lowbidder).profits(j);
            end 
            market.as(j) = 0;
            market.ds(lowbidder) = 0;

            % Some defenders may have lost their bid, update their choice
            losers(buyers(buyers~=lowbidder)) = 1;
        end
    end
end

if enable == 1
    % Subcontract Round, do this until no one wants to switch from their
    % current job to another
    numswitchers = Inf;
    while numswitchers > 0
        % First to check to see if any attackers have not been allocated (maybe
        % defender subcontracted and left it)
        aopen = [];
        for j=1:A
            if isempty(as(j).award)
                aopen = [aopen, j];
            end

            % Also reset who wants to join each attacker
            as(j).req = [];
        end

        % Go through each of the defenders to see if they want to switch
        numswitchers = 0;

        % For each defender, if they want to switch find their best switch
        for i=1:D
            % Start by resetting who they would want to go for
            ds(i).a = [];
            ds(i).swprofit = 0;

            % They had no award after main contract round, so no attackers open
            if isempty(ds(i).award)
                best_profit = 0;
                potential = ds(i).order; % attackers interested in
                for k=1:numel(potential)
                    % Compute the extra revenue you would get from working with di
                    j = potential(k);
                    if isempty(find(aopen==j,1)) % attacker isnt in the non allocated group           
                        % Compute the extra revenue you would get from working
                        % with group to get aj
                        coalition = as(j).award; % coalition has at least one
                        Pcoalfails = 1;
                        for k=1:numel(coalition)
                            di = coalition(k);
                            Pcoalfails = Pcoalfails*(1-P(di,j));
                        end
                        profit = r(a(j).t).val*(Pcoalfails - Pcoalfails*(1-P(i,j)));
                        if profit > best_profit % Then you would prefer attacker j over current
                            best_profit = profit;
                            ds(i).a = j;
                            ds(i).swprofit = profit;
                        end
                    end
                end
            elseif ds(i).award ~= ds(i).order(1) % They didn't get first choice
                best_profit = ds(i).cprofit;

                % First search through unallocated attackers
                for k=1:numel(aopen)
                    j = aopen(k);
                    profit = ds(i).profits(j);
                    if profit > best_profit
                        best_profit = profit;
                        ds(i).a = j;
                        ds(i).swprofit = profit;
                    end
                end

                % Now get quotes from defenders who got your priority picks
                potential = ds(i).order(1:find(ds(i).order==ds(i).award) - 1); % priority attackers

                % Note that "potential" is attackers numbers
                for k=1:numel(potential)
                    j = potential(k); % attacker number

                    if isempty(find(aopen==j,1)) % attacker isnt in the non allocated group           
                        % Compute the extra revenue you would get from working
                        % with group to get aj
                        coalition = as(j).award; % coalition has at least one
                        Pcoalfails = 1;
                        for k=1:numel(coalition)
                            di = coalition(k);
                            Pcoalfails = Pcoalfails*(1-P(di,j));
                        end
                        profit = r(a(j).t).val*(Pcoalfails - Pcoalfails*(1-P(i,j)));
                        if profit > best_profit % Then you would prefer attacker j over current
                            best_profit = profit;
                            ds(i).a = j;
                            ds(i).swprofit = profit;
                        end
                    end
                end
            end

            % Add the defender that wants to switch to the attackers requests
            if ~isempty(ds(i).a)
                numswitchers = numswitchers + 1;
                as(ds(i).a).req = [as(ds(i).a).req, i];
            end
        end

        % Now all defenders that did not get their priority attacker assignment
        % has evaluated if switching from their current to another will
        % increase their profit, if true, the ds(i).a has new desired and
        % ds(i).swprofit as how much profit they would get if switching, and
        % ds(i).cprofit has profit if they stayed in the same role

        % Now update roles by seeing who is best to join each attacker
        for j=1:A
            if ~isempty(as(j).req)
                best_increase = 0;
                best_i = 0;

                % Figure out from all defenders that want to join coalition to
                % fight aj by leaving their current, which will increase its profit the most
                for k=1:numel(as(j).req)
                    i = as(j).req(k); 
                    increase = ds(i).swprofit - ds(i).cprofit;
                    if increase > best_increase
                        best_i = i;
                        best_increase = increase;
                    end
                end

                % Update attacker the defender i used to be on
                if ds(best_i).award ~= 0
                    old_j = ds(best_i).award;
                    as(old_j).award = as(old_j).award(as(old_j).award ~= best_i);
                end

                % Update defender i to reflect this switch
                ds(best_i).award = j;
                ds(best_i).cprofit = ds(best_i).swprofit;
                ds(best_i).swprofit = 0;

                % Update attacker j to reflect this switch
                as(j).award = [as(j).award, best_i];
            end
        end
    end
end

% Update actual d array
for i=1:D
    if ~isempty(ds(i).award)
        d(i).a = ds(i).award;
    else
        d(i).a = 0;
    end
end

end

