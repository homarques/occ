%END Dataset overload

function m = end(a,k,n);

		
	if n == 1
		error('Two-dimensional subscript expected')
	elseif n == 2
		m = size(a,k);
    if m == 0
      error('2D datafile subscription not possible as feature size is unknown')
    end
	else
		error('Datafile should be 2-dimensional')
	end

	return
