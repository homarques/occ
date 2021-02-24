%PKLIBSVC Automatic radial basis LIBSVM, using NULIBSVC and the Parzen kernel
%
%   [W,KERNEL] = PKLIBSVC(A,ALF)
%   [W,KERNEL] = A*PKLIBSVC([],ALF)
%   [W,KERNEL] = A*PKLIBSVC(ALF)
%
% INPUT
%   A   Dataset
%   ALF Parameter, default 1
%
% OUTPUT
%   W       Mapping: Radial Basis Support Vector Classifier
%   KERNEL  Untrained mapping, representing the optimised kernel
%
% DESCRIPTION
% This routine provides a radial basis support vector classifier based on
% LIBSVC. It estimates the kernel width SIGMA by the the value found by
% PARZENC. The kernel width used is ALF*3*SQRT(2)*SIGMA. This is much
% faster than the gridsearch used by RBLIBSVC and may performs equally well.
%
% Note that LIBSVC is a multi-class classifier and thereby uses a single
% kernel.
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, MAPPINGS, LIBSVC, NULIBSVC, RBLIBSVC, PARZENC, SVC

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function [w,kernel] = pklibsvc(varargin)

  argin = shiftargin(varargin,'scalar');
  argin = setdefaults(argin,[],1);
  mapname = 'PK-LIBSVM';
  if mapping_task(argin,'definition')
    w = define_mapping(argin,'untrained',mapname);
    
  elseif mapping_task(argin,'training')			% Train a mapping.
  
    [a,alf] = deal(argin{:});

    if size(a,1) <= 1000
      [v,sig] = parzenc(a);
    else
      [v,sig] = parzenc(gendat(a,1000));
    end
    kernel = proxm([],'r',alf*3*sig*sqrt(2));
    [w,J] = libsvc(a,kernel);
    %[w,J,nu] = nulibsvc(a,kernel);
    w = setname(w,mapname);
  end

