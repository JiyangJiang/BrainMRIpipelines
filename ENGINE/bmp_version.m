function bmpver = BMP_version (module, varargin)

	BMP_ver {1,1} = '0.0.1 (internal testing)';
	BMP_ver {2,1} = datetime ('10-12-2022', 'InputFormat', 'dd-MM-yyyy');
	BMP_ver {3,1} = sprintf (	[ ... 
								'10-12-2022 : Internal testing.\n'... 
								'Release note line 2\n'... 
								]);

	ADNI_ver{1,1} = '0.0.1';
	ADNI_ver{2,1} = datetime ('10-12-2022', 'InputFormat', 'dd-MM-yyyy');
	ADNI_ver{3,1} = sprintf ([...
								'10-12-2022 : DICOM-to-BIDS mappings from ADNI study data. T1w, FLAIR and ASL are supported.\n' ...
								]);

	BIDS_ver{1,1} = '0.0.1';
	BIDS_ver{2,1} = datetime ('10-12-2022', 'InputFormat', 'dd-MM-yyyy');
	BIDS_ver{3,1} = sprintf ([...
								'10-12-2022 : version 0.0.1 of ADNI preset.\n' ...
								]);


	if iscell (module)

		for i = 1 : size (module, 1)

			switch module{i,1}

				case 'BMP'

					cprintf (bmp_convention ('s'), '%s : ', mfilename);
					cprintf (bmp_convention ('t'), 'Version of ');
					cprintf (bmp_convention ('k'), '''BMP'' ');
					cprintf (bmp_convention ('t'), ' is enquired.\n');

					bmpver.BMP = BMP_ver{1,1};

					if nargin == 2 && strcmp(varargin{1},'verbose')

						bmpver.BMP = sprintf (['%s\n%s\n%s'], BMP_ver{1,1}, BMP_ver{2,1}, BMP_ver{3,1});

					end

				case 'ADNI'

					cprintf (bmp_convention ('s'), '%s : ', mfilename);
					cprintf (bmp_convention ('t'), 'Version of presets for ');
					cprintf (bmp_convention ('k'), '''ADNI'' ');
					cprintf (bmp_convention ('t'), ' is enquired.\n');

					bmpver.ADNI = ADNI_ver{1,1};

					if nargin == 2 && strcmp(varargin{1},'verbose')

						bmpver.ADNI = sprintf (['%s\n%s\n%s'], ADNI_ver{1,1}, ADNI_ver{2,1}, ADNI_ver{3,1});

					end

				case 'BIDS'

					cprintf (bmp_convention ('s'), '%s : ', mfilename);
					cprintf (bmp_convention ('t'), 'Version of module ');
					cprintf (bmp_convention ('k'), '''BIDS'' ');
					cprintf (bmp_convention ('t'), ' is enquired.\n');

					bmpver.BIDS = BIDS_ver{1,1};

					if nargin == 2 && strcmp(varargin{1},'verbose')

						bmpver.BIDS = sprintf (['%s\n%s\n%s'], BIDS_ver{1,1}, BIDS_ver{2,1}, BIDS_ver{3,1});

					end

			end
		
		end

	else

		cprintf (bmp_convention ('s'), '%s : ', mfilename);
		cprintf (bmp_convention ('e'), 'Input argument ');
		cprintf (bmp_convention ('k'), '''module''');
		cprintf (bmp_convention ('e'), ' is not a cell array.\n');

	end

end

