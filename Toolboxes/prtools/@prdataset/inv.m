%INV Dataset overload

% $Id: inv.m,v 1.3 2007/03/22 07:45:54 duin Exp $

function c = inv(a)
				
	nodatafile(a);
	c = inv(a.data);
	%DXD we don't pack this into a dataset, feature or bug?
	%RD  feature: it enable smooth use of datasets in standard Matlab
	%    commands
return
