%DD_COSTC Cost curve
%
%        C = DD_COSTC(A,W)
%        C = DD_COSTC(A*W)
%        C = A*W*DD_COSTC
%
% INPUT
%   A      one-class dataset
%   W      trained one-class classifier
%
% OUTPUT
%   C      cost curve
%
% DESCRIPTION
% The costs and the probability cost function are returned in a
% structure containing the fields pcf and cost. This cost curve is
% defined in:
%@inproceedings{ drummond00explicitly,
%    author = "Chris Drummond and Robert C. Holte",
%    title = "Explicitly representing expected cost: an alternative to {ROC} representation",
%    booktitle = "Knowledge Discovery and Data Mining",
%    pages = "198-207",
%    year = "2000"},
%
% SEE ALSO
% dd_roc, roc_hull, rocsqueeze, plotcosts, simpleroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function c = dd_costc(a,w)
global rtype;
if isempty(rtype)
	rtype = 'hull';
end

if nargin==0

	c = prmapping(mfilename,'fixed');

elseif nargin == 1

	% simplify the code by using dd_roc (where the FN and FP are already
	% nicely computed):
	if ~isfield(a,'err')
		r = dd_roc(a);
	else
		r = a;
	end

	% find the convex hull:
	switch rtype
	case 'hull'
		e = roc_hull(r);
	case 'mid'
		r = rocsqueeze(r);
      e = r.err(1:end-1,:) + diff(r.err)/2;
      e = [0 1; e; 1 0];
	case 'org'
		e = r.err;
	end
	% first get the errors:   [FN FP]
	e = e(end:-1:1,:);
	% convert it into:  [FP TP]
	fp = e(:,2);
	fn = e(:,1);
	% find the places where the curves cross:
	dfp = diff(fp);
	dfn = diff(fn);
	pcf = dfp./(dfp-dfn);

	% the last pcf is always 1 (a bit strange maybe, but with this I can
	% easily perform vector operations together with fn and fp)
	pcf = [pcf; 1];

	% the output cost values:
	cost = fp + (fn-fp).*pcf;

	% store everything into one structure:
	c.op = r.op;
	% the first value in the curve is not a crossing of two lines and is
	% added explicitly:
	c.pcf = [0; pcf];
	c.cost = [0; cost];

else

	% Separate mapping and dataset are given, so we have to map the data
	% first:
	ismapping(w);
	istrained(w);

	c = feval(mfilename,a*w);

end

return
