%DISPLAY Display datafile information

% $Id: display.m,v 1.4 2009/02/19 12:34:02 duin Exp $

function display(a)
	
	if (isempty(a))
   disp('Empty datafile')
	else
		m = a.prdataset.objsize;
		c = size(getlablist(a),1);
		if c == 1
			clas = ' class';
		else
			clas = ' classes';
		end
		m = num2str(m);
		%k = num2str(k);
		c = num2str(c);
    if strcmp(a.type,'raw')
      raw = ' raw';
    else
      raw = '';
    end
    name = getname(a.prdataset);
    if ~isempty(name)
      name = [name ', '];
    end
		
		switch a.prdataset.labtype
			case 'crisp'
				siz = num2str(classsizes(a));
				disp([name a.type ' datafile with ' m ' objects in ' c ' crisp classes: [' siz ']'])
			case 'soft'
				disp([name a.type ' datafile with ' m ' objects in ' c ' soft classes'])
			case 'targets'
				disp([name a.type ' datafile with ' m ' objects with ' c ' targets'])
			end
		end
return;
