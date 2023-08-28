Cerebrovascular reactivity (CVR) in VCI study
=============================================

Existing resources for data processing
--------------------------------------
* `phys2cvr GitHub <https://github.com/smoia/phys2cvr>`_.
* `Quantiphyse CVR analysis tutorial <https://quantiphyse.readthedocs.io/en/latest/cvr/tutorial.html>`_.
* ?? `repidtide for time lag correlation analysis <https://github.com/bbfrederick/rapidtide>`_
* Data analysis in CVR MRI section of Liu et al.'s `CVR technical review <https://pubmed.ncbi.nlm.nih.gov/29574034/>`_

Quantiphyse CVR analysis
-------------------------
error message: ModuleNotFoundError: No module named 'pandas._libs.interval'

solution:
pip uninstall pandas
pip install pandas
pip3 install --upgrade pandas

module load qt/5.15.5 gcc/12.2.0

conda install -c conda-forge gsettings-desktop-schemas
cd /srv/scratch/cheba/NiL/Software/miniconda3/envs/quantiphyse/share/glib-2.0/schemas
glib-compile-schemas $(pwd)
GSETTINGS_SCHEMA_DIR=$(pwd) quantiphyse

Visualise etCO2 trace
---------------------

..  code-block::

	% This is a MATLAB script

	setenv ('TZ', 'Australia/Sydney');  % otherwise a warning of system time zone setting will araise.
	cw = radtable ('0004_2023_08_24_15_57_02_cw.csv', "Delimiter", ",", "ReadVariableNames", true);
	cw.Time = datetime (string (cw.Time, 'hh:mm:ss.SSS'), 'Format', 'HH:mm:ss.SSS'); % convert duration to datetime

	% zoom-in to useful duration (need to change accordingly)
	experiment_start = '16:12:00.000';
	experiment_end   = '16:20:00.000';

	cw_new = cw (cw.Time > datetime (experiment_start, 'InputFormat', 'HH:mm:ss.SSS') & ...
				 cw.Time < datetime (experiment_end, 'InputFormat', 'HH:mm:ss.SSS'), :);

	plot (cw_new.Time, cw_new.CO2_mmHg_)

Figure below shows what I get from pilot scan:

..  figure:: figures/CVR_pilotScan_etCO2trace.jpg
	:width: 1000
	:align: center

According to `the CVR technical review <https://pubmed.ncbi.nlm.nih.gov/29574034/>`_:

* During **room-air** breathing, the bottom of signal is approximately **zero** because there is virtually no CO2 in the inhaled room-air.
* During **room-air** breathing, the upper peak of the signal is approximately **40 mmHg**, which is typical of etCO2 for a healthy volunteer.
* During **hypercapnia** breathing, the bottem of signal is **38 mmHg**, which is consistent with CO2 content in the inhaled air of 5% of atmospheric pressure (760 mmHg).
* During **hypercapnia** breathing, the upper peak of the signal is typically 8-12 mmHg above the value during room-air breathing, i.e. **48-52 mmHg**.

Figure below shows a typical CO2 trace recording (copied from `the CVR technical review <https://pubmed.ncbi.nlm.nih.gov/29574034/>`_)

..  figure:: figures/CVR_technicalReview_etCO2trace.png
	:width: 400
	:align: center


**---=== TO BE CONTINUED ===---**

