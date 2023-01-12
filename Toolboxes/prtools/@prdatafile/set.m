%SET Set datafile fields 
%
%    A = SET(A,VARARGIN)
%
% Sets datafile fields (given as strings in VARARGIN) of the datafile A.
% E.G.: A = SET(A,'dir',DIR,'nlab',NLAB).
% This is not different from using the field specific routines
% (e.g. SETDIR(A,DIR)
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% PRDATAFILE, GET

% $Id: set.m,v 1.3 2007/04/26 08:48:18 duin Exp $

function a = set(a,varargin)

	if isempty(varargin), return, end

	%[m,k,c] = getsize(a);
	for j=1:2:nargin-1
		
		field = varargin{j};
		
		if j == nargin+1
			error('No data found for field')
		else
			v = varargin{j+1};
		end
		
		switch field

    	case {'ROOTPATH','rootpath'}
			 a.rootpath = v;
		 case {'FILES','files'}
			 a.files = v;
		 case {'RAW','raw'}
			 a.raw = v;
		 case {'PREPROC','preproc'}
			 a.preproc = v;
		 case {'POSTPROC','postproc'}
			 a.postproc = v;
		 otherwise
			 a.prdataset = set(a.prdataset,field,v);
		end
	end

	return
