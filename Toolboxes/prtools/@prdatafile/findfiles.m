%FINDFILES   
%
%	J = FINDFILES(A,DIR,FILES)
%
% Find in datafile A the objects that are related to the files listed in
% the character array or cell array FILES stored in the subdirectory DIR
% (usually the class name).

function J = findfiles(a,dir,files)

if nargin < 3, files = []; end

afiles = getfiles(a);
fident = getident(a,'file_index');

if isempty(dir)
	n = 1;
else
	if isempty(afiles)
		n = 1;
	else
		n = find(strcmp(dir,afiles{1}));
	end
end

if isempty(n)
	error('Directory not found in datafile')
end

K = find(fident(:,1) == n);
if isempty(files)
	J = K;
else	
	if ischar(files)
		files = cellstr(files);
	end
	J = [];
	afiles2n = deblank(cellstr(afiles{2}{n}));
	for j=1:length(files)
		f = find(strcmp(files{j},afiles2n));
		if ~isempty(f)
			J = [J;K(find(fident(K,2)==f))];
		end
	end
end
