%NEURC Automatic neural network classifier with one hidden layer
% 
%   [W,UNITS] = NEURC(A)
%   [W,UNITS] = A*NEURC
%
% INPUT
%   A      Dataset
%
% OUTPUT
%   W      Trained feed-forward neural network mapping
%   UNITS  Number of hidden units used.
%
% DESCRIPTION
% Automatically trained feed-forward neural network classifier. All
% parameters are automatically determined. The number of hidden units is
% the number of objects of A divided by the number of classes plus the
% feature size, but at least 2 and at most 100. 
%
% The network is initialised by RNNC and trained by LMNC. Training is
% stopped when the performance measured by an automatically generated
% tuning set of 1000 objects does not improve anymore or after the time set
% by PRTIME. 
%
% Uses the Mathworks' neural network toolbox.
%
% This routine escapes to KNNC if no classes have more than 2 objects.
% 
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% MAPPINGS, DATASETS, LMNC, BPXNC, GENDATK, REGOPTC, PRTIME

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com

function [out,units] = neurc (varargin)

  checktoolbox('nnet');
  
  mapname = 'AutoNeuralNet';
  if mapping_task(varargin,'definition')
    out = define_mapping(varargin,'untrained',mapname);
    
  elseif mapping_task(varargin,'training')      % Train a mapping.
  
    a = varargin{1};
    islabtype(a,'crisp');
    
    % remove too small classes, escape in case no two classes are left
    [a,m,k,c,lablist,L,out] = cleandset(a,3,knnc([],1)); 
    
    if ~isempty(out), return; end
    units = max(min(floor(m/(c+k)),100),2);
    a = testdatasize(a);
    a = setprior(a,getprior(a,0));

    % train a network.
    % Reproducability: always use same seeds. 
    randstate = randreset(1); 
    t = gendatk(a,1000,2,0.5);     % Create tuning set based on training set.     
    v = rnnc(a,units);            % initialize by a random network
    w = lmnc(a,units,inf,v,t);    % Find LMNC mapping.
    e = t*w*testc;                % Calculate classification error.
    w = allclass(w,lablist,L);
    randreset(randstate); % return original state
    out = setname(w,mapname);

  else % Evaluation
    
    [a,w] = deal(varargin{1:2});
    nodatafile(a);
    data = getdata(w); 

    if (length(data) > 1)
      
      % "Old" neural network - network is second parameter: unpack.
      data = getdata(w); weights = data{1};
      pars = data{2}; numlayers = length(pars);

      output = a;                       % Output of first layer: dataset.
      for j = 1:numlayers-1
        % Number of inputs (n_in) and outputs (n_out) of neurons in layer J.
        n_in = pars(j); n_out = pars(j+1);

        % Calculate output of layer J+1. Note that WEIGHTS contains both
        % weights (multiplied by previous layer's OUTPUT) and biases
        % (multiplied by ONES).

        this_weights = reshape(weights(1:(n_in+1)*n_out),n_in+1,n_out);
        output = sigm([output,ones(m,1)]*this_weights);

        % Remove weights of this layer.
        weights(1:(n_in+1)*n_out) = [];
      end
    else
      % "New" neural network: unpack and simulate using the toolbox.
      net = data{1};
      output = sim(net,+a')';
    end;

    % 2-class case, therefore 1 output: 2nd output is 1-1st output.
    if (size(output,2) == 1)
      output = [output (1-output)]; 
    end

    % Output is mapped dataset.
    out = setdat(a,output,w);
  
  end

return
  
