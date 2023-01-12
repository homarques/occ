%DISPLAY Display dataset information

% $Id: display.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function display(a)
	
	if (isempty(a,'objsize'))
   disp('Empty dataset.')
	else
		[m,k,c] = getsize(a);
		if c == 1
			clas = ' class';
		else
			clas = ' classes';
		end
		m = num2str(m);
		k = num2str(k);
		s = num2str(c);
		if (~isempty(a.name))
			name = [a.name ', '];
		else
			name = '';
		end
		
		switch a.labtype
			case 'crisp'
        if c > 20
          disp([name m ' by ' k ' dataset with ' s clas])
        else
          siz = num2str(classsizes(a));
          disp([name m ' by ' k ' dataset with ' s clas ': [' siz(:)' ']'])
        end
			case 'soft'
				disp([name m ' by ' k ' dataset with ' s ' soft ' clas])
			case 'targets'
				disp([name m ' by ' k ' dataset with ' s ' targets'])
			end
		end
return;
