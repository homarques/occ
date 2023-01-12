%READDATAFILE Read one of the datafiles
%
%    [B,NEXT,J] = READDATAFILE(A,N)
%
% INPUT     
%   A           Datafile
%   N           Number of the file to be read
%
% OUTPUT
%   B           Dataset stored in file N
%   NEXT        Number of next file to be read, 0 if done
%   J           Indices of objects in A
%
% DESCRIPTION
% A datafile points to a dataset stored in a series of files. This
% routine reads one of them, but is designed to read them all in a loop.
% A typical example is shown below, computing the overall mean per class.
% If the preprocessing field of A is set, the listed preprocessing is
% applied before returning.
% If the mappings field of A is set, the listed mappings are applied
% to B before returning.
%
% As the objects in A may be randomly distributed over the files, a 
% reordering is performed internally in this routine. Consequently,
% objects may be returned in a different order than stored in A.
%
% [m,k,c] = getsize(a);
% nobjects = classsizes(a);
% u = zeros(c,k);
% next = 1;
% while next > 0
%    [b,next] = readdatafile(a,next)
%    u = u + meancov(b) .* repmat(nobjects',1,k);
%    if next <= 0, break; end
% end
% u = u ./ repmat(classsizes(a)',1,k);
%
% SEE ALSO (<a href="http://prtools.tudelft.nl/prtools">PRTools Guide</a>)
% PRDATASET, DATAFILE

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [b,next,J] = readdatafile(a,n,fid,all)

  %disp('readdatafile1')

  if nargin < 3, fid = 1; end %DXD,standard output
  if nargin < 2, n = 1; end
  
  if nargin < 4
    try
      % standard call, might go wrong if after preprocessing
      % objects have still different sizes
      [b,next,J] = feval(mfilename,a,n,fid,0);
    catch me
      ss = lasterror;
      if strcmp(ss.identifier,'FeatSize')
        % objects are of different size after preprocessing
        % perhaps postprocessing makes this OK. Try one by one.
        b = prdataset(a);
        next = 0;
        J = [1:size(a,1)]';
      else
        rethrow(me)
        % call again to generate authentic error message
        % as rethrow is not sufficiently clear
        % [b,next,J] = feval(mfilename,a,n,fid,0);
      end
    end
    return
  end
      

  % set up administration between calls
  persistent file_index  % file_index in a.ident
  persistent R           % unique files indices in file_index
  persistent rindex      % index in R
  persistent nfile1      % # file/subdir in top dir of datafile (class level)
  persistent nfile2      % # file in subdir (object level)
  persistent N           % indices in A of objects in subdir 
  persistent numfiles    % total number of files in subdir

  persistent fnames      % filenames in subdir
  persistent obj_read    % number of objects read
  persistent clear_pers  % clearing flag
  persistent waittext
  
  if n == 1 && 0 % for debugging only
    [ss,ii] = dbstack;
    [path,name1] = fileparts(ss(2).name);
    [path,name2] = fileparts(ss(3).name);
    if length(ss) > 3
      [path,name3] = fileparts(ss(4).name);
    else
      name3 = [];
    end
    disp([name3 ' ' name2 ' ' name1])
  end
  
  admin = 0;
  if n==1 || isempty(clear_pers) || clear_pers % new, first call, clear admin
    file_index = [];
    nfile1 = [];
    nfile2 = [];
    N = [];
    numfiles = [];
    fnames = [];
    featsize = [];
    obj_read = 0;
    file_index = getident(a.prdataset,'file_index');
    R = unique(file_index(:,1));
    rindex = 1;
    clear_pers = 0; % avoid clearing in next call, unless desired
    if fid > 0  % fid == 0 in case of admin calls that dont start a full loop.
      prprogress(fid,'Processing %5i objects:\n',getobjsize(a)); 
      prprogress(fid,'%5i\n',0); 
      waittext = sprintf('Processing %i objects: ',getobjsize(a));      
      prwaitbar(getobjsize(a),waittext);
    elseif nargout == 1
      % admin call that just needs a single object processed
%       a = datasubsref(a,1); % circumvent Matlab bug
      admin = 1;
    end
  else
    % disp([1 n])
  end
  
  if isempty(a.rootpath)
    a.rootpath = pwd;
  end
  
  if strcmp(a.type,'raw') 
    % in a.files directory names are stored. Their files have to be read
    if rindex > numel(R)
      disp('this should not happen')
    end
    nfile1 = R(rindex);
    dfile = a.files{1}{nfile1};
    if isempty(numfiles)            % new (next) sub dir
      N = find(file_index(:,1) == nfile1);
      fnames = a.files{2}{nfile1};
      fnames = fnames(file_index(N,2),:);
      numfiles = size(fnames,1);
      nfile2 = 1;                   % prepare for first object in dir
    end
    fnam = deblank(fnames(nfile2,:)); % the file in which it is stored
    [pathstr2,name2,fext2] = fileparts(fnam);
    b = a.prdataset(N(nfile2),:);       % prepare for dataset, read and preproces
    
    %disp(fullfile(a.rootpath,dfile,fnam))
  
    b = preprocessing(b,a.preproc,fullfile(a.rootpath,dfile,fnam),fext2);
    
    nfile2 = nfile2+1;              % prepare for next file
    if nfile2 > numfiles            % ready for next directory
      numfiles = [];
      rindex = rindex + 1;
    end
    obj_read = obj_read+1;          % another object done
    ready = (n >= size(file_index,1));
    J = N(nfile2-1);
  
  elseif strcmp(a.type,'half-baked') || strcmp(a.type,'mature') || ...
    strcmp(a.type,'cell') || strcmp(a.type,'patch')

    % run over all files in a.files

    if isempty(numfiles)            % get max # of files to be handled
      numfiles = max(file_index(:,1));
    end
    J = [];
    n = n-1;
    while isempty(J)                % skip empty files
      n = n+1;
      J = find(file_index(:,1) == n);
    end
    
    if strcmp(a.type,'patch')
      % we need to read images here and split them
      % into patches to find the individual objects (patches)
      preproc = a.preproc;
      fname = fullfile(a.rootpath,a.files{n});
      [pathstr,name,fext] = fileparts(fname);
      if isempty(preproc(1).preproc)
        d = imread(fname,fext(2:end)); 
      else
        d = feval(preproc(1).preproc,fname,preproc(1).pars{:});
      end
      % d is now an image, which patches do we need?
      L = file_index(J,2);
      if admin == 1  % terrible admin call which tries to find a single object
        L = L(1);  % to inspect possible sizes
        J = J(1);
      end
      nbands = size(d,3);  % images might be multi-band
      for j=1:nbands       % patch extraction is programmed band by band
                           % pars are stored in preproc(1,2)
        dd = im_patch(d(:,:,j),preproc(1,2).pars{:},L); 
        if ndims(dd) == 2  % in case of a single patch, ndim = 2, shift it right
          dd = shiftdim(dd,-1);
        else               % in case of multiple patches, ndim = 3, patched in dim 3
          dd = shiftdim(dd,2); % rotate to the left, two places
        end
        % patches are now stored as [npatches,row_patch,col_patch]
        if j==1            % combine all binds in dim 4
          dat = zeros([size(dd),nbands]);
        end
        dat(:,:,:,j) = dd;
      end
      % every multi-band patch should be a single object in a cell
      data = cell(1,size(dat,1));
      for j=1:size(dat,1)
        data{j} = squeeze(dat(j,:,:,:));
      end
      targets = [];
      preproc = a.preproc;
      preproc(1:2) = [];   % we already did some preprocessing, delete them
      a.preproc = preproc; % dangerous???? better to handle pointer?
              
    elseif strcmp(a.type,'half-baked') 
      s = prload(fullfile(a.rootpath,a.files{n}));
      f = fieldnames(s);
      d = s.(f{1});
      L = file_index(J,2);
      data = getdata(d(L,:));
      fsize = getfeatsize(d);
      data = reshape(data,[size(data,1),fsize]);
      if isempty(d.targets)
        targets = [];
      else
        targets = d.targets(L,:);
      end
      
    elseif strcmp(a.type,'cell') 
      s = prload(fullfile(a.rootpath,a.files{n}));
      f = fieldnames(s);
      d = s.(f{1});
      L = file_index(J,2);
      if admin == 1
        L = L(1);  % admin call needs just a single object
        J = J(1);
      end
      data = d(L);
      targets = [];
      if ~isempty(a.preproc) && isempty(a.preproc(1).preproc)
        preproc = a.preproc;
        preproc(1).preproc = 'void';
        a.preproc = preproc;
      end
      
    else % mature

      dfile = fullfile(a.rootpath,a.files(n).name); % file to be processed
      fd = fopen(dfile,'r');          % open it
      lendata = prod(a.files(n).sized); % we know length of data part
      lentarg = a.files(n).sizet;       % and length of target part
      data = zeros(length(J),lendata);
      targets = zeros(length(J),lentarg);
      if isempty(a.files(n).nbits)
        nbytes = 8;
      else
        nbytes = round(a.files(n).nbits/8);
      end
      for j=1:length(J)                 % run over all objects in this file
        offset = (file_index(J(j),2)-1)*(lendata+lentarg)*nbytes;
        status = fseek(fd,offset,'bof');% set file pointer
        if status < 0
          error('Error in reading datafile');
        end
        data(j,:) = (fread(fd,lendata,a.files(n).prec))'; % read data
        if lentarg > 0                                    % read targets
          targets(j,:) = (fread(fd,lentarg,a.files(n).prec))';
        end
      end
      fclose(fd);
      if ~isempty(a.files(n).scaled)     % rescale data if scaled
        data = double(data)/a.files(n).scaled - a.files(n).offsetd;    
        data = reshape(data,[length(J) a.files(n).sized]);
      end
      if ~isempty(a.files(n).scalet)     % rescale targets if scaled
        targets = double(targets)/a.files(n).scalet - a.files(n).offsett;
      end
      
    end

     b = a.prdataset;                    % reconstruct dataset
     b = b(J,:);
    imtot = [];
    m = size(b,1);
    if ~isempty(a.preproc) && ~isempty(a.preproc(1).preproc)
%       if fid > 0      
%         stext = sprintf('Preprocessing %i objects: ',size(b,1));
%         prwaitbar(size(b,1),stext);
%       end
      for j=1:m               % preprocess images one by one
%          if fid > 0            % no waitbar in case of admin call
%            prwaitbar(m,j,[stext int2str(j)]);
%          end
        if iscell(data)
          im1 = preprocessing(data{j},a.preproc,[],[]);
        elseif iscell(a.files) % true for some datafile types
          fsize = size(data);  % subscription looses shap
          if length(fsize) > 2
            fsize = fsize(2:end);
          end
          im1 = preprocessing(reshape(data(j,:),fsize),a.preproc,[],[]);
        else
          fsize = a.files(n).sized;
          if (length(fsize) == 1)
            fsize = [1,fsize];
          end
          im0 = reshape(data(j,:),fsize);
          im1 = preprocessing(im0,a.preproc,[],[]);
        end
        if j==1
          imtot = zeros(size(b,1),prod(size(im1)));
        end
        if length(im1(:)) ~= size(imtot,2)
          if fid > 0
            %prwaitbar(0);
          end
          error('FeatSize','Feature sizes of objects differ, conversion not possible');
        else
          imtot(j,:) = im1(:)';
        end
      end
      if fid > 0
        %prwaitbar(0);
      end
      b = setdat(b,imtot);
      fsize = size(im1);
      if (length(fsize) == 2) && (min(fsize) == 1)
        fsize = max(fsize);
      end
    else
      if iscell(data)
        dat = zeros(length(data),prod(size(data{1})));
        fsize = size(data{1});
        datsize = length(data);
        for i = 1:datsize
          dat(i,:) = data{i}(:)';
        end
        data = dat;
        b = setdata(b,reshape(data,datsize,prod(fsize)));
      else
        fsize = size(data);
        if size(data,1) == size(b,1)
          fsize = fsize(2:end);
          b = setdata(b,data);
        elseif size(b,1) == 1
          b = setdata(b,reshape(data,[1 size(data)]));
        else
          fsize = size(data);
          datsize = fsize(1);
          fsize = fsize(2:end);
          b = setdata(b,reshape(data,datsize,prod(fsize)));
        end
      end
    end
 %   if size(b,2) ~= prod(fsize) % why this restriction ???  <<<<<<<<<<<<<------------
      b = setfeatsize(b,fsize);
  %  end
    if ~isempty(targets)
      b.targets = targets;
    end
     obj_read = obj_read+length(J);     % another set of objects read!
    ready = (n >= numfiles);
    
  elseif strcmp(a.type,'pre-cooked')

    % run over all files in a.files
    if isempty(numfiles)            % get max # of files to be handled
      numfiles = max(file_index(:,1));
    end
    J = [];
    n = n-1;
    while isempty(J)                % skip empty files
      n = n+1;
      J = find(file_index(:,1) == n);
    end
    dfile = fullfile(a.rootpath,deblank(a.files(n,:)));
    b = preprocessing([],a.preproc,dfile);
     obj_read = obj_read+length(J);     % another set of objects read!
    ready = (n >= numfiles);
      
  end

  debug_this = 0;
  if debug_this
    disp('readdatafile debugging')
    b
    struct(a.postproc)
    parsc(a.postproc)
  end
  
  b = b*a.postproc;                    % postprocessing
  
  if fid > 0
    objread = obj_read+1; % add 1 to progress as display comes after processing
    prprogress(fid,'%5i \n',objread);
    prwaitbar(getobjsize(a),objread,[waittext int2str(objread)]);
%   disp(objread)
  end
  
  next = n+1;
  if ready              % we are done, make sure next call is a fresh one.
    clear_pers = 1;
%   disp('ready')
    next = -1;
    if fid > 0
      prwaitbar(0);
    end
  end
  
  b = prdataset(b); % make sure b is a dataset

return

function error_mess(yes)

  if yes
    error('No correctly organised datafile directory found')
  end
  
return

function b = preprocessing(b,preproc,dfile,fext)

  if isempty(preproc(1).preproc) && ~isempty(dfile) 
    f = imread(dfile,fext(2:end)); % minimum preprocessing is imread
    fsize = size(f);
  else
    [f,fsize] = preprocg(b,preproc,dfile);
  end

  if isa(f,'uint8') || isa(f,'uint16')
    f = double(f)/256; % needed for color image display !!!! TERRIBLE !!!!!
  elseif isa(f,'double') || isa(f,'char')
    ;
  else
    f = double(f);
  end
  
%   if length(fsize) == 2 && fsize(1) == 1 % why ???
%     fsize = fsize(2);                   % bad in case of 1-D signals
%   end
                                   % store result
  if isdataset(f)
    b = f;
  elseif ~isempty(dfile)
    f = f(:)';
    if ~isempty(b.data) && (length(f) ~= size(b.data,2))
      error('Retrieved datasizes should be constant for datafile directory')
    end
    %fsize = getfeatsize(b);
    %b = setdata(b,double(f));      % in dataset
    b = setdata(b,f);               % in dataset, preserve chars
    if numel(f) == prod(fsize)      % set correct image size if it fits
      b = setfeatsize(b,fsize);
    end
  else
    b = f;                         % or as doubles
  end
  
return

function [f,fsize] = preprocg(b,preproc,dfile)

  [n,k] = size(preproc);
  fsize = [];
  for j=1:n                        % n > 1 in case of horzcat of datafiles
                                   % not used like this, when is n > 1 ??
    if ~isempty(dfile)             % raw datafile
      if isempty(preproc(j,1).pars)
        g = feval(preproc(j,1).preproc,dfile);
        if ndims(g) < 3 && size(g,2) == 1
          g = g'; % avoid column reading
        end
        if isa(g,'uint8') || isa(g,'uint16')
          g = double(g)/256; % needed for color image display
        elseif isa(g,'double') || isa(g,'char')
          ;
        elseif isa(g,'struct')
          fields = fieldnames(g);
          g = double(getfield(g,fields{1}));
        else
          g = double(g);
        end
      elseif strcmp(preproc(j,1).preproc,'void')
        g = b;
      else
        g = feval(preproc(j,1).preproc,dfile,preproc(j,1).pars{:});
      end
    elseif strcmp(preproc(j,1).preproc,'void')
      g = b;
    elseif ~isempty(preproc(1).preproc)  % we already have data in b (mature datafile)
      g = feval(preproc(1).preproc,b,preproc(j,1).pars{:});
    else
      g = b;
    end
    if k > 1         % more preprocessing
      for i=2:k
        if strcmp(preproc(j,i).preproc,'concatenate')
%           if i == k
%             fsize = [size(h) 2];  % preserve image size for featsize
%             g = [g(:)' h(:)'];
%           else          % concatenation in preprocessing in cells
%             g = {g h};  % should be handled in next preprocessing step
%           end
%           % end in a cell array for k >2, wrong!
          if i==2, g = {g}; end
          h = preprocg(b,preproc(j,i).pars,dfile); % read next datastream in h
          g = [g {h}];
          if i == k
            fsize = [size(h) 2];  % preserve image size for featsize
            g = [g{:}];
          end
        else
          if ~isempty(preproc(j,i).preproc)
            if iscell(g) % expecting dyadic operation after concatenation
              try
                g = feval(preproc(j,i).preproc,g,preproc(j,i).pars{:}); % seems wrong
              catch
                gg = [];
                for n=1:length(g)
                  gg = [gg feval(preproc(j,i).preproc,g{n},preproc(j,i).pars{:})];
                end
                g = gg;
              end
            else
              %g = feval(preproc(j,i).pars{:},g,preproc(j,i).pars{:});
              g = feval(preproc(j,i).preproc,g,preproc(j,i).pars{:});
            end
          end
        end
      end
    end
    if j==1
      f = g;                % preserve images as they are
      if isempty(fsize)
        fsize = size(f);
      end
      if isa(f,'dip_image')
        fsize([1 2]) = fsize([2 1]);
      end
    else
      f = [f(:)' g(:)'];    % concatenation, ready for handling by postprocessing
      if isempty(fsize)
        fsize = length(f);
      end
    end
  end
  
return

function a = readtext(file) 
% read text file
fid = fopen(file);
a = fscanf(fid,'%c');
fclose(fid);
return
