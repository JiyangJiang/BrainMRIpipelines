function colour = bmp_convention_MATLAB (keyword)

	switch keyword

		case {'text'; 'txt'; 't'}

			colour = '*[0.1, 0.5, 0.3]'; % bold dark green

		case {'error'; 'err'; 'e'}

			colour = '*red';

		case {'keyword'; 'kw'; 'k'}

			colour = 'magenta';

		case {'path'; 'pth'; 'p'}

			colour = 'Strings';  % purple colour

		case {'warning'; 'wn'; 'w'}

			colour = '*SystemCommands'; % orange colour

		case {'script'; 'sc'; 's'}

			colour = '*[0.1, 0.1, 0.8]';

		otherwise

			colour = keyword;

	end


end