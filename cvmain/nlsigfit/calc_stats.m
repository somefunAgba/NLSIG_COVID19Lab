function goodfit_stats = calc_stats(y_data,y_est,dy_data,dy_dx_est,p,n_ips)
%CALC_STATS Compute goodness of fit (coefficient of determination) stats.
%
% Inputs:
%   y_data, actual values
%   y_est, estimated values
%   p, number of regression model parameters
%
% Output:
%   goodfit_stats structure

p = p*n_ips;

% See http://facweb.cs.depaul.edu/sjost/csc423/documents/f-test-reg.htm

% errors/variances sum of squares

y_mean  = mean(y_data); % average value: sum(y_data)/numel(y_data)
% sum of squares for the total variance in the data samples
tots = y_data - y_mean;
SST = sum((tots.^2));    
% sum of squares for the regression model
regs = y_est - y_mean;
SSM =  sum((regs.^2));
% sum of squares for the residuals (errors)
res = y_data - y_est;
SSE = sum((res.^2));

% normalized residuals to values between 0 and 1
res_normcdf = normalize(y_data,'range') - normalize(y_est,'range');

%% R2 and F-stats

% coefficient of determination / goodness of fit
% compute R-squared, but avoid divide by zero warning
if ~isequal(SST,0)
  R2 = 1 - (SSE./SST); % or SSM/SST
elseif isequal(sst,0) && isequal( sse, 0 )
    R2 = NaN;
else % SST==0 && SSE ~== 0
    % This is unusual, so try to determine if sse is just round-off error
    if ( sqrt(abs(SSE)) < sqrt(eps)*mean(abs(y_data)) )
        R2 = NaN;
    else
        R2 = -Inf;
    end
end

% p, number of regression parameters          

% Degrees of Freedom for Model Variance
dfm = p - 1; % p > 1
% Degrees of Freedom for Error Variance or residuals
dfe = numel(y_data) - p;
% Degrees of Freedom for Total Variance
dft = numel(y_data) - 1; % or  dfm + dfe

% mean of squares
% for (explained) variance of the regression model
MSM = SSM/dfm;
% for (unexplained) variance of the error residuals
MSE = SSE/dfe;
% for variance of the total data samples
MST = SST/dft;

% adjusted R2
R2a = 1 - (MSE/MST);

% root mean square error: standard error of estimate
RMSE = sqrt(MSE);

% calculate F-statistics
Fval = MSM/MSE;

% 95% CI on (dfm, dfe)
% good fit has < 0.05 confidence level p-value 
% Significance probability for regression
pval = fcdf(1./max(0,Fval),dfe,dfm);

%% KS and DKW stats

% calculate D statistic(s)
% number of samples
Nres = numel(res); 
% euclidean distance or 2-norm
De = vecnorm(res,2);
% chebyschev distance or max-norm or sup-norm
Dc = vecnorm(res,Inf);
% average 2-norm or RMS distance
% Dr = rms(res); % vecnorm(res,2)/sqrt(Nres)

% normalized D statistic
normDc = vecnorm(res_normcdf,Inf);

% alpha-level of significance
alphalvl = 0.01; 

% DKW Inequality CI Constant
C = exp(1);
% C = 2;

% Critical value at alpha-level of the 
% one-sample Kolmogorov-Smirnov test for samples of size n
% valE1 = sqrt((1/(2*Nres))*log(C/alphalvl));
% two-sample Kolmogorov-Smirnov test for samples of size n
valE2 = sqrt((1/(dft))*log(C/alphalvl));

if valE2*normDc > valE2
    KSgof = alphalvl;
elseif valE2*normDc <= valE2
    KSgof = 1-alphalvl;
end

% Modified CI Constants
% euclidean, 2-norm
% change to 2;
valEe = sqrt((1/(2))*log(C/alphalvl))*De;
% valEi = sqrt((1/(1))*log(C/alphalvl))*Dc;
% chebyschev, max-norm
% change to 1;
c =  1/32;
valEi = sqrt((1/c)*log(C/alphalvl));
valEi = valEi.*valE2.*Dc;
% CI value for Y
ciE = valEi;

% DY sum of squares for the residuals (errors)
dres = dy_data - dy_dx_est;
%dSSE = sum((dres.^2));

dDc = vecnorm(dres,Inf);
dvalEi = sqrt((1/(1))*log(C/alphalvl))*dDc;
% CI value for DY
dciE = dvalEi;

% Set up GOF structure
goodfit_stats = struct('residuals', res,'dresiduals', dres,...
    'SSE', SSE, 'RMSE', RMSE, 'MST', MST,...
    'R2', R2,'R2a', R2a, ...
    'dfe', dfe, ...
    'Fval', Fval, 'pval', pval, ...
    'ciE', ciE, 'valEi', valEi, 'valEe', valEe, ...
    'dciE', dciE, 'KSgof', KSgof, 'normDc', normDc ...
    );

% %... set logaritmic scale
% set(gca, 'YScale', 'log')
% 
% tx1 = sprintf('%s: Covid-19 epidemic %s',...
%     country,datestr(time0+length(length(C))-1));

end