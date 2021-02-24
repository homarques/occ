%CHECKTOOLBOX Check avialability of toolbox
%
%     N = CHECKTOOLBOX(TOOLBOX)
%
% INPUT
%		TOOLBOX	 String with toolbox name
%
% OUTPUT
%		N        Flag, 1/0 if the toolbox is/isn't in the path
%
% DESCRIPTION
% Checks whether TOOLBOX is in the path.

function n = checktoolbox(name)

  if nargin == 0 || ~ischar(name)
    error('No input string found')
  end

  if nargout == 0

    switch lower(name)
      case('stats_svmtrain')
        if exist('stats/svmtrain') ~= 2
          error([prnewline 'Matlab''s Support Vector Classifier, svmtrain, ' ...
            prnewline 'is not found. Add the stats toolbox to the path or upgrade it.'])
        end
      case('naivebayes')
        if exist('NaiveBayes.m','file') ~= 2
          error([prnewline 'Matlab''s naive Bayes classifier, NaiveBayes, ' ...
            prnewline 'is not found. Add the stats toolbox to the path or upgrade it.'])
        end
      case('classificationknn')
        if exist('ClassificationKNN.m') ~= 2
          error([prnewline 'Matlab''s nearest neighbor classifier, ClassificationKNN, ' ...
            prnewline 'is not found. Add the stats toolbox to the path or upgrade it.'])
        end
      case('classificationdiscriminant')
        if exist('ClassificationDiscriminant') ~= 2
          error([prnewline 'Matlab''s linear classifier, ClassificationDiscriminant, ' ...
            prnewline 'is not found. Add the stats toolbox to the path or upgrade it.'])
        end
      case('classificationtree')
        if exist('ClassificationTree.m') ~= 2
          error([prnewline 'Matlab''s decision tree classifier, ClassificationTree, ' ...
            prnewline 'is not found. Add the stats toolbox to the path or upgrade it.'])
        end
      case('libsvm')
        if exist('libsvm/svmtrain') ~= 3
          error([prnewline 'The LIBSVM package is not found.' prnewline ...
          'Add it to the Matlab path or download it from ' ...
          '<a href="http://www.csie.ntu.edu.tw/~cjlin/libsvm/">here</a>.'])
        end
      case('diplib')
        if exist('diplib','dir') ~= 7
          error([prnewline 'The DIPIMAGE package is needed and not found.' ...
          prnewline 'Add it to the Matlab path or download it from ' ...
          '<a href="http://www.diplib.org/">here</a>.'])
        end
      case('nnet')
        if isoctave
          error('PRTools neural network routines are not implemented for Octave')
        elseif exist('logsig','file') ~= 2
          error([prnewline 'The neural network toolbox/package is not found.' prnewline ...
          'Please add it to the path or load it.'])
        end
      otherwise
        if exist(name,'dir') ~= 7
          error([prnewline 'The ' upper(name) ' toolbox is needed. ' ...
            'Please add it to the path.'])
        end
    end

  else

    n = exist(name,'dir') == 7;

  end

return
  
  
    
      