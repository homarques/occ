%IM_MAXF Fixed mapping for maximum filter (DIP_Image)
%
%	B = IM_MAXF(A,SIZE,SHAPE)
%	B = A*IM_MAXF([],SIZE,SHAPE)
%	B = A*IM_MAXF(SIZE,SHAPE)
%
% INPUT
%   A        Dataset with object images dataset (possibly multi-band)
%   SIZE     Filter width in pixels, default SIZE = 7
%   SHAPE    String with shape:'rectangular', 'elliptic', 'diamond'
%            Default: elliptic
%
% OUTPUT
%   B        Dataset with filtered images
%
% SEE ALSO (<a href="http://37steps.com/prtools">PRTools Guide</a>)
% DATASETS, DATAFILES, DIP_IMAGE, MINF

% Copyright: R.P.W. Duin, r.p.w.duin@37steps.com
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = im_maxf(varargin)

	argin = shiftargin(varargin,'scalar');
  argin = setdefaults(argin,[],7,'elliptic');
  if mapping_task(argin,'definition')
    b = define_mapping(argin,'fixed');
    b = setname(b,'Maximum filter');
  else
    [a,size,shape] = deal(argin{:});	
    if isa(a,'prdataset') % allows datafiles too
      isobjim(a);
      b = filtim(a,mfilename,{size,shape});
    elseif isa(a,'double') || isa(a,'dip_image') % here we have a single image
      if checktoolbox('dipimage')
        a = 1.0*dip_image(a);
        b = maxf(a,size,shape);
      else
        diplibwarn
        %prwarning(1,'Rectangular shape only')
        shape = ones(size,size);
        b = ordfilt2(a,size*size,shape);
      end
    end
  end
	
return
