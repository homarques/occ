%IMREAD Datafile overload
%
%     IM = IMREAD(A,N)
%
% The images (raw data) of the datafile A are returned as a cell array.
% The preprocessing and postprocessing defined for the datafile are
% skipped.
% If the index vector N is given, just these images are returned.
% In case a single image is requested, IM is not a cell array but double.
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% DATA2IM

function b = imread(a,n)

	if nargin > 1, a = reorderdset(a,n,0); end

  findex = getident(a,'file_index');
  type = gettype(a);
	if isempty(a.rootpath)
		rootpath = pwd;
	else
		rootpath = a.rootpath;
	end
	preproc = a.preproc;
 
	c = {};
	L = [];
  for n=1:max(findex(:,1))
    J = find(findex(:,1) == n);
		
    if ~isempty(J)
		   
      switch(type)
        
        case 'raw' 					
					dfile = a.files{1}{n};
					fnames = a.files{2}{n};
          K = findex(J,2);
					fnames = fnames(K,:);
					for j=1:length(K)
          	fnam = deblank(fnames(j,:)); 
    				[pathstr,name,fext] = fileparts(fnam);
						fnam = fullfile(a.rootpath,dfile,fnam);
  					if isempty(preproc(1).preproc)
							f = imread(fnam,fext(2:end)); 
						else
							f = feval(preproc(1).preproc,fnam,preproc(1).pars{:});
						end
						c = {c{:} f};
					end
					
				case 'patch'
					dfile = a.files{1}{n};
					fnames = a.files{2};
          K = findex(J,2);
					fnames = fnames(K,:);
					
          fnam = deblank(dfile); 
    			[pathstr,name,fext] = fileparts(fnam);
					fnam = fullfile(a.rootpath,fnam);
  				if isempty(preproc(1).preproc)
						f = imread(fnam,fext(2:end)); 
					else
						f = feval(preproc(1).preproc,fnam,preproc(1).pars{:});
					end
					g = im_patch(f,preproc(2).pars{:});
					c = {c{:} g{:}};
					
					
				otherwise
					error('Datafile type not implemented')
			end
		end
		L = [L;J];
	end
	if length(L) > 1
		b = cell(size(c));
		b(L) = c;
	else
		b = c{1};
	end
          
return