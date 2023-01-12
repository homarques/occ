%SETLABELS Reset labels of mapping
%
%    W = SETLABELS(W,LABELS,J)
%
% Resets the LABELS field of the mapping W. If the index vector J
% is given, just the corresponding labels are updated.

% $Id: setlabels.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function w = setlabels(w,labels,J)
	[m,k] = size(w);

  if nargin < 2
    w.labels = [];
    return
  end
  
	if isempty(labels)
		labels = [1:k]';
	end

	if nargin > 2   % only a subset of the labels have to be changed
		kk = size(w.labels,1);
		if max(J) > kk || min(J) < 1
			error('Label indices out of range')
		end
		n = length(J);
		if size(labels,1) ~= n
			error('Number of labels does not match number of feature indices')
		end
	else            % all labels have to be set
		n = size(labels,1);
		J = [1:n];
		if n < w.size_out
			error('Insufficient number of labels supplied')
		end
		w.labels = [];
	end

	% When no label strings are supplied, we have to use default
	% values: use  digits 1, 2, .. etc.
	if isempty(w.labels)
		if iscell(labels)
			w.labels = num2cell(64+[1:k]');
		elseif ischar(labels)
			w.labels = char(zeros(k,size(labels,2)));
		else
			w.labels = [1:k]';
		end
	end

	if (iscell(labels) ~= iscell(w.labels)) || (ischar(labels) ~= ischar(labels))
		error('Label lists should be both strings or numeric')
	end
	% Finally set the labels!
	w.labels(J,:) = labels(J,:);

return
