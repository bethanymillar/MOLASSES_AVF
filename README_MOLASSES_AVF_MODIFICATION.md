#### NAME
**MOLASSES**

MOLASSES stands for *MO*dular *LA*va *S*imulation *S*oftware for *E*arth *S*cience.
 
#### DESCRIPTION

MOLASSES is an in-progress fluid flow simulator, written in C. 
The MOLASSES model relies on a cellular automata algorithm to
estimate the area inundated by lava flows.

#### CODE REQUIREMENTS 

1) MOLASSES requires the GDAL C libraries and a C compiler. GDAL libraries and development files are available for many systems (http://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries); install both the gdal library and the header (development) files. We have tested this program on computers that use the C compiler gcc.

2) MOLASSES requires the memory management software GC (http://www.hboehm.info/gc/). Install both library (lib) and header files (dev). See the [readme](/external_files/readme/) file in the external_files directory for additional info.

3) MOLASSES requires RNGLIB, a C library which implements random number generators (https://people.sc.fsu.edu/~jburkardt/c_src/rnglib/rnglib.html). Also, See the [readme](/external_files/readme/) file in the external_files directory for additional info.

4) MOLASSES requires a DEM (Digital Elevation Model) in a format recognized by the GDAL code library. The DEM should extend beyond the boundaries of the lava flow(s). 

        NOTE: DSM used for AVF Application.

5) MOLASSES requires a configuration file that is specified on the command line when executing the code. 

#### LICENSE

    Copyright (C) 2015-2020  
    Laura Connor (lconnor@usf.edu)
    Jacob Richardson 
    Charles Connor

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>. 

#### COMPILING and INSTALING THE CODE - ORIGNIAL METHOD

Before compilation of MOLASSES modify the makefile in the top-level directory for your use. 

1) Check to make sure that the path to GDAL and gcc are properly set. 

2) The module names at the top of the Makefile may be changed to accomadate alternative model algorithms. This name refers to a new C-code file (for the alternative algorithm) in the src directory.

To compile and install MOLASSES execute the following commands:

		make
		make install

'make' compiles the code; 'make install' copies the code to a 'bin' (program) directory specified in the top-level makefile.

#### PROGRAM EXECUTION - ORIGINAL METHOD

To run molasses type:

	$PATH_TO_MOLASSES/$molasses $config_file

where $PATH_TO_MOLASSES indicates where the executable code is located, $molasses indicates the exact name of the compiled code, and $config_file indicates the name of the configuration file. It is most convenient if the configuration file resides in your working directory. 

##### ALTERED EXCECUTION METHOD - AVF Application

The main components of the code remain unaltered. All external libraries, methods of linking through the main MOLASSES and src makefiiles remain as intended. 

Edits are as follows:
- Execution by .sh script 
        The shell scripts are seperated into Scenario and region (as the AVF is large and the DSM input is too large to be processed by the model) 
        Each Shell Script calls the configuration file that matches the scenario and region.
            for Example run_lava_flowB_North.sh is for Scenario B and for the area North, when it is run it excecutes ./bin/molasses.ljc ./inputs/molasses_B_N.conf
            This configuration file calls the vent input file ./inputs/vents_B.utm and dsmN.grd
        The Shell script registers the calling of vents_B.utm and accesses a file with the full vents of Scenario B in the North area, it then goes down the list and updates the vents_B.utm file after each one is completed. This automates the moidel moving through the list of vent X and Y coordinates in ./inputs/vent_source/vents_North_B.utm.

        After each model is simulated, it outputs an ASCII file in the place holder FlowB0 this file is then converted to a csv and stored in the flow outputs directory under a folder of the scenario and then of the area, i.e., ./flow_outputs/B/flowB_North it is named flowB and the X and Y coordinates are attached.

        The shell script then converts the csv to a Raster in .tif format and outputs this with the same file name as the csv in the same folder. This is in a format ready to be put into any GIS software for analysis.  

#### RUNNING AVF MODIFIED MOLASSES

ALL that is required from user is the following 3 steps:
1) For the Scenario and area of interest go to the MOLASSES/inputs/vent_source/ directory and open the utm of interest...
    i.e., MOLASSES/inputs/vent_source/vents_North_B.utm

2) Next, copy the first set of X and Y coordinates and go back to the MOLASSES/inputs and paste the X and Y coordinates into the appropie vents file...
    i.e., MOLASSES/inputs/vents_B.utm.

3) To run: cd to the MOLASSES directory and use ./run_lava_flow[chosen scenario]_[chosen area].sh
    i.e., ./run_lava_flowB_North.sh

NOTE: user can run multiple models through the different schell scripts at once, but because the shell scripts in the same scenario share files (molasses_[chosen scenario].ljc and the virtual environments molasses_[chosen scenario]), users can ONLY RUN ONE MODEL PER SCENARIO AT ONE TIME.
Additional issues may come up if two models of different scenarios are sharing the same dsm input, so be cautious here, although can be done.




MORE DETAILED METHODS
The model was set up on a Windows 64 GB RAM computer using the Windows Subsystem for Linux (WSL) program Ubuntu. The MOLASSES repository by Connor L., Richardson J., and Connor C., from GitHub under the geoscience-community-codes, was copied to a local C drive, ensuring connections between files were preserved. Following the code requirements documentation, GDAL C libraries and C compiler were installed, specifically the C compiler gcc, as recommended. Within the external libraries folder, a memory management software GC was installed from the GitHub repository under the ivmai/bdwgc repository. The RNGLIB C library for random number generators (for further code development) was installed. As directed through the associated README documents, the libraries were compiled and connected within the MOLASSES makefile and MOLASSES/src makefile. The input files then need to be modified. This includes a DEM, vent coordinates and modifications to the MOLASSES configuration file which defines the input parameters. 

Connecting the inputs to MOLASSES 

The model requires a .grd format for the DEM/DSM input. A new symbolic link, dsm[area of focus].grd, was created for each of the five DSMs in the MOLASSES/inputs directory. The vent x and y coordinates were extracted from the grid vents located within each of the five DSM areas in ArcGIS Pro and saved as vents_[area of focus]_[scenario] in .utm format for the MOLASSES code compatibility (located in MOLASSES/inputs/vent_sources). The MOLASSES code when downloaded from GitHub, was initially set up to work for a single X and Y vent location at a time, therefore an adjacent file vents_[scenario].utm will hold the coordinates of the current vent location of analysis (saved in MOLASSES/inputs). The configuration file in the inputs directory defines both the .grd and .utm input files for the range of files dependent on these inputs. This allows the model to be run with changes of vent or area without issues for dependent files.     

MOLASSES Execution 

Following the initial MOLASSES model set up from GitHub, and the proper connecting of dependant files, the following commands were used to compile and install the code.  

make clean   make    make install  

Then, to run the program, the following commands, which correspond to the MOLASSES compiled code and configuration file location, were executed in the MOLASSES directory.  

./bin/molasses.ljc ./inputs/molasses.conf  

Initiating the simulation showing the text 'MOLASSES is a lava simulator' within the terminal. Here, it runs through all input and lava parameters defined in the configuration file and then initiates lava being distributed from the vent source location, detailing the active cells and the remaining Volume to erupt. After the successful simulation, the text "ASCII Output file: flow0 successfully written" is outputted alongside the elapsed time. This output holds the coordinates of each cell inundated, the thickness experienced, and the pre-and post-lava flow elevation. 

Expanding from one location to all 

While the previous steps remain similar to the past functionality of the MOLASSES code, with each run producing a lava flow related to the defined inputs to match the scenario within the configuration file, further alterations were made in the execution process due to the scale of this AVF Ellipse lava flow hazard analysis. This was achieved through shell scripts incorporating an iterative process, looping through the vents for each scenario for each area of interest (see supplementary material). The main configuration file was duplicated for each scenario and its area of interest (e.g. molasses_[scenario]_[area of interest].conf), while the compiled code was duplicated for each scenario (e.g molasses_[scenario].ljc) as well as the place holder flow0 output. Within the shell script, the files are called in the same way of execution as intended originally. This enabled each scenario to be run independently and run for areas of focus.    

The shell script then achieves the automatic and iterative process by accessing the adjacent input vents file (vents_[area of focus]_[scenario].utm), selecting the next pair of X and Y coordinates, and echoing them into vents_[scenario].utm within the configuration file. The output file "flow[scenario]0" is temporarily held as an ASCII file and is then ordered to be converted to a CSV file by calling a Python script that extracts the X and Y coordinates from the vent location and appends it to the output title, i.e., flow[scenario]_[X]_[Y].csv. The CSV conversion enables easier data management and further investigation into the lava flow details. After the CSV file is created, a further Python file is called, which rasterises the CSV file output using the X and Y coordinates alongside the thickness, producing a TIFF file. This enables an output that can be put into any GIS software to be analysed. The output hazard data for Scenarios B, F and D are provided as supplementary material.   