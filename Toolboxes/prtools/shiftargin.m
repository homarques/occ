%SHIFTARGIN Shift input arguments conditionally
%
%  ARGOUT = SHIFTARGIN(ARGIN,CONDITION,NPAR)
%
% INPUT
%   ARGIN      Cell array with function input arguments (VARARGIN)
%   CONDITION  Type of first argument, e.g. 'double','char','prmapping'.
%              'scalar' and 'vector' are allowed as well. See ISSCALAR.
%              'vector' holds only for numeric row vectors.
%              'integer' for integer doubles or INTX variables.
%              'last' tests whether argument NPAR is the last in the call.
%              This can also be a cell array of conditions. If one of them 
%              holds it is fulfilled.
%   NPAR       Argument number in ARGIN to be tested.
%
% OUTPUT
%   ARGOUT     If CONDITION is false ARGIN, else [{[]} ARGIN]
%
% DESCRIPTION
% Function input arguments stored in ARGIN, usually VARARGIN of the calling 
% function, are conditionally shifted to avoid the need to add superfluous
% empty placeholders ([]) as the first argument in mapping definitions.
% Shifting will be skipped if the second argument is a trained mapping.
%
% SEE ALSO
% DATASETS, MAPPINGS

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function argout = shiftargin(argin,type,npar)

if nargin < 3, npar = 1; end
if (numel(argin) < npar) || ...
   (numel(argin) >= npar && isempty(argin{npar})) || ...
   (numel(argin) > 1 && ismapping(argin{2}) && istrained(argin(2)))
   % no shifting in case of trained mapping as 2nd argument
  argout = argin; 
  return
end

if nargin > 1
  if ~iscell(type)
    type = {type};
  end

  n = numel(type);
  shift = false;
  for j=1:n
    if islogical(type{j})
      shift = type{j};
    else
      switch type{j}
      case 'last'
        if numel(argin) <= npar
          shift = true;
        end
      case 'scalar'
        if isa(argin{npar},'numeric') && numel(argin{npar}) == 1
          shift = true;
        end
      case 'vector'
        if isnumeric(argin{npar}) && isvector(argin{npar}) && size(argin{npar},1) == 1
          shift = true;
        end
      case 'integer'
        if isa(argin{npar},'double')
          shift = isequal(argin{npar},round(argin{npar}));
        end
      otherwise
        if isa(argin{npar},type{j})
          shift = true;
        end
      end
    end
    if shift, break; end
  end
else
  shift = true;
end


if shift
  argout = [{[]},argin];
else
  argout = argin;
end