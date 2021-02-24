function [ aggR ] = RRF( R )
%RRF Reciprocal rank fusion algorithm. Generates an aggregated rank based
%on a set of ranked lists.
%
%   INPUTS:
%       R           -> Set of ranks to be aggregated. Numeric matrix with as many rows as the number of
%       ranked lists. 
%   OUTPUTS:
%       aggR        -> Aggregated Rank


%% The formula for this aggregation is the following:
%% RRFScore( d belongs to D ) = sum_{r belongs to R}(1/(k+r(d))) 
%% According to 'Reciprocal Rank Fusion outperforms Condorcet and Individual Rank Learning Methods', k is 60.
%% No much explanation was given on the reason.
K=60;

aggR = zeros(1,size(R,2));
%% For each ranked item
for i=1:size(R,2)
    aggR(i)= sum(1./(K + R(:,i) ));
end

aggR = -aggR;


end

