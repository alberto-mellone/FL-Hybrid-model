%%%%%% 1. SYSTEM REQUIREMENTS %%%%%%
- Dependencies: to run the code an installation of MATLAB R2020b (Version 9.9.0.1495850 Update 1) or later versions is required. The following MATLAB toolboxes are required: System Identification Toolbox (Version 9.13), Optimization Toolbox (Version 9.0), Control System Toolbox (Version 10.9). Any operating system supporting MATLAB R2020b is required.

- Version of software for testing: the code has been tested on a Windows 10 Pro machine and MATLAB R2020b.

- Non-standard hardware: no non-standard hardware is required.


%%%%%% 2. INSTALLATION GUIDE %%%%%%
- Instructions: no installation is required.

- Typical install time: N/A.

%%%%%% 3. DEMO %%%%%%
- Instructions to run demo: open in MATLAB one of the files with name formatted as "run_XXX.m" and either a) press F5 on the keyboard or b) click on "Run" in the EDITOR tab. Alternatively, type the name of the file to run in the MATLAB command window without the ".m" extension and press enter.

- Expected output: MATLAB figures displaying the same plots presented in the "Results" section of the manuscript.

- Expected run time: a few seconds, normally no more than one minute. 

%%%%%% 4. INSTRUCTIONS FOR USE %%%%%%
- Software description: the software is organised in several MATLAB m files and two csv files. As far as the the MATLAB files are concerned, six of them are scripts reproducing the results presented in the manuscript, and the remaining ones are MATLAB functions used within the scripts. The two csv files represent the dataset on COVID-19 active cases, deaths, and recoveries in Israel and Germany. A brief description of the m files is as follows.
	+ run_XXX.m: scripts to run to obtain the plots displayed in the "Results" section of the manuscript.
	+ alpha_computation.m: computation of the coefficients a_i at the start of a lockdown (see "Methods" in the manuscript).
	+ get_alpha2_3.m: computation of the coefficients a_2 and a_3 given a_0 and a_1 (see "Methods" in the manuscript).
	+ get_data.m: extraction of data on COVID-19 cases, deaths, and recoveries from csv files and sets it up for subsequent use.
	+ get_suder.m: conversion from the lockdown phase compartments to free phase compartments.
	+ SUDER.m: dynamics of the free phase specified in the format required by the built-in MATLAB function ode45.
	+ LD_SUDER.m: dynamics of the lockdown phase specified in the format required by the built-in MATLAB function ode45.
	+ suder_model.m: dynamics of the free phase specified in the format required by the System Identification Toolbox function idnlgrey
	+ lockdown_model.m: dynamics of the lockdown phase specified in the format required by the System Identification Toolbox function idnlgrey
	+ simulate_lockdown.m: fitting of the lockdown phase sub-models (see "Methods" in the manuscript) and simulation of the lockdown phase.
	+ simulate_suder.m: fitting of the free phase suder sub-model (see "Methods" in the manuscript) and simulation of the free phase.

- How to run the code on the data: the MATLAB scripts "run_XXX.m" can be run as described at point 3. They internally run the previously mentioned MATLAB functions, which in turn process the data extracted from the csv files to produce the model predictions.

- Reproduction instructions: by running the MATLAB scripts "run_XXX.m", the figures displayed in the "Results" section of the manuscript are obtained as an output.


	
