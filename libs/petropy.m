function H = petropy(x,n,tau,method,accu)
% The petropy function calculates the permutation entropy of data series.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% version 1.1, 27.02.2015:
%   - corrected typo in the description ('same' -> 'equal')
%   - line 106: changed unique-function in newer MATLAB-version
%
% Permutation Entropy
%
% H = PETROPY(X,N,TAU,METHOD,ACCU) computes the permutation entropy H of 
% a scalar vector X, using permutation order N, time lags from TAU and 
% METHOD to treat equal values. The ACCU parameter describes the accuracy 
% of the values in X by the number of decimal places.
%
% x      - data vector (Mx1 or 1xM)
% n      - permutation order
% tau    - time lag scalar OR time lag vector (length = n-1)
% method - method how to treat equal values
%   'noise' - add small noise
%   'equal' - allow same rank for equal values
%   'order' - consider order of appearance (first occurence --> lower rank)
% accu   - maximum number of decimal places in x 
%         (only used for method 'noise')
%
% References:
%
% Bandt, C.; Pompe, B. Permutation Entropy: A Natural Complexity 
% Measure for  Time Series. Phys. Rev. Lett. 88 (2002) 17, 174102
%
% Riedl, M.; Müller, A.; Wessel, N.: Practical considerations of 
% permutation entropy. The European Physical Journal Special Topics 
% 222 (2013) 2, 249–262
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example:
%
% H = petropy([6,9,11,12,8,13,5],3,1,'order');
% H = 
%       1.5219
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 5, accu = 4; end
if nargin < 4, method = 'order'; end

x = x(:);
M = length(x);
equal = false;

if n*log10(n)>15, error('permutation dimension too high'); end
if (length(tau)) > 1 && (length(tau) ~= n-1), error('time lag vector has to have n-1 entries'); end
if ((n-1)*min(tau) >=M) || max(tau) >= M, error('too few data points for desired dimension and lags'); end


switch lower(method)
    case {'noise'}
        %disp('Method: add small noise')
        x = x + rand(M,1)*10^(-accu-1);
    case 'equal'
        %disp('Method: allow equal ranks')
        equal = true;
    case 'order'
        %disp('Method: consider order of occurrence')
    otherwise
        error('unknown method')
end

if length(tau) > 1
    tau = reshape(tau,length(tau),1);
    tau = sort([0;tau]);
    % build n x (M-tau(n))-matrix from shifted values in x
    shift_mat = zeros(n,M-tau(n));
    for ii=1:n
        shift_mat(ii,:) = x(tau(ii)+1:M-tau(n)+tau(ii));
    end
else
    % vectorized
    shift_mat_ind = reshape(0:tau:(n-1)*tau,[],1) * ones(1,M-(n-1)*tau) +...
        ones(n, 1) * reshape(1:(M-(n-1)*tau),1,[]);
    shift_mat = x(shift_mat_ind);
end

if equal
    % allow equal values the same index
    ind_mat = zeros(size(shift_mat));
    for ii=1:size(ind_mat,2)
        [~,~,ind_mat(:,ii)]=unique(shift_mat(:,ii),'first');
    end
else
    % sort matrix along rows to build rank orders, equal values retain
    % order of appearance
    [~, sort_ind_mat] = sort(shift_mat,1);
    ind_mat = zeros(size(sort_ind_mat));
    for ii=1:size(ind_mat,2)
        ind_mat(sort_ind_mat(:,ii),ii) = 1:n;
    end
end
% assign unique number to each pattern (base-n number system)
ind_vec = n.^(0:n-1) * (ind_mat-1);

% find first occurence of unique values in 'ind_vec' and use
% difference to determine length of sequence of the same numbers; e.g.
% sort_ind_vec = [21 21 11 19 11], unique_values = [11 19 21],
% ia = [1 3 4]: 11 occurs on places #1 and #2, 19 on #3 and 21 on #4 and #5
[~,ia,~] = unique(sort(ind_vec), 'first');

% use the following line, if you are using MATLAB in a lower version than
% 8.3:
% permpat_num = diff([ia (length(ind_vec)+1)]);
permpat_num = diff([ia; (length(ind_vec)+1)]);

permpat_num = permpat_num/sum(permpat_num);

% compute permutation entropy
H = -sum(permpat_num .* log2(permpat_num));


