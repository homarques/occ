%HSV2RGB Dataset overload
%
%  B = HSV2RGB(A)

% Copyright: R.P.W. Duin
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = hsv2rgb(a)
	
		
  if isdataset(a)
    isdataim(a);
    im = data2im(a);
    imsize = getfeatsize(a);
    out = feval('hsv2rgb',im);
    if isobjim(a)
      b = im2obj(out,imsize);
      b = setdat(a,getdata(b));
      b = setfeatsize(b,imsize);
    else
      b = im2feat(out);
      b = setdat(a,b);
    end
	elseif isdatafile(a)
    isdataim(a);
    b = filtm(a,mfilename);
    imsize = getfeatsize(a); 
    if isobjim(a)
      imsize = getfeatsize(a); 
      b = setfeatsize(b,imsize);
    else
      imsize = getobjsize(a); 
      b = setobjsize(b,imsize);
    end
  else
    error('Unexpected data type of input')
  end
return
