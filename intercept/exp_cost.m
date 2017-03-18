function cost = exp_cost(M,c,P,Ca,G,cfunc)
% Computes the expected cost given current probabilities, resource values,
% and allocation
% Inputs: M: DxA allocation matrix
%         c: 1xR resource value vector
%         P: DxA interception probability matrix
%         Ca: 1xD cost of allocating defender vector
%         G: RxA resource/attacker pairing matrix
D = size(M,1);
A = size(M,2);
R = size(c,2);

if strcmp(cfunc,'Total')
    cost = c*(ones(R,1)-exp(G*log(ones(A,1)-exp(log(.9999*ones(D,A)-M.*P)'*ones(D,1))))) + (M*ones(A,1))'*Ca';
elseif strcmp(cfunc,'Incremental')
    cost = ones(1,R)*(c'.*G)*exp(log(.9999*ones(D,A)-M.*P)'*ones(D,1));
end

end