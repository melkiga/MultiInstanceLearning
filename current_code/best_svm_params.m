function [max_val,indBestC,indBestSigma] = best_svm_params(A)
%% Returns best value in A with min C and max sigma

% find best accuracy with respect to columns (sigma)
[max_vals_sigma, ind_sigma] = max(A);

% find best accuracy
max_val = max(max_vals_sigma);

% find best accuracy with respect to rows
max_ind_C = find(max_vals_sigma == max_val);
indBestSigma = max_ind_C(end);
indBestC = ind_sigma(indBestSigma);

