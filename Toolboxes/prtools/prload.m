%PRLOAD Similar to LOAD matfile, but converts old datasets, datafiles, mappings
%
%  PRLOAD FILE
%  PRLOAD(FILE,VARARGIN)
%  S = PRLOAD(FILE,VARARGIN)
%
% PRLOAD behaves similar to LOAD, but converts PRTools4 variables to
% PRTools5.

function out = prload(file,varargin)

warning('off','MATLAB:unknownObjectNowStruct');
warning('off','MATLAB:indeterminateFields');
warning('off','MATLAB:unknownElementsNowStruc');
warning('off','MATLAB:elementsNowStruc');

pp = prrmpath('prtools','@dataset','dataset');   % make sure we have prtools dataset
finishup = onCleanup(@() addpath(pp)); % restore path afterwards

warnstat = warning;
warning off;
if isempty(varargin)
   %DXD: we need an exception because load only wants to accept strings:ty[
   s = load(file);
else
   s = load(file,varargin{:});
end
warning(warnstat);

if ~isstruct(s)
  if nargout > 0
    out = s;
  else
    [pp,varname,ext] = fileparts(file);
    assignin('caller',varname,s);
  end
  return
end  

fields = fieldnames(s);
for j=1:numel(fields)
  x = getfield(s,fields{j});
  if isa(x,'dataset') % should not happen after path removal
    % we are trapped by Matlab's dataset
    % assume we have an old-fashioned prtools4 dataset
    x = struct(x);
  end
  if isstruct(x)
    if isfield(x,'mapping_file')
      x = prmapping(x);
    elseif isfield(x,'rootpath')
      x = prdatafile(x);
    elseif isfield(x,'labtype')
      x = prdataset(x);
    elseif isfield(x,'ll')
      x = prdataset(x);
    end
  end
  s = setfield(s,fields{j},x);
end

if nargout > 0
  f = fieldnames(s);
  if numel(f) == 1 && nargin == 2
    out = s.(f{1});
  else
    out = s;
  end
else
  for j=1:numel(fields)
    assignin('caller',fields{j},getfield(s,fields{j}));
  end
end
  

