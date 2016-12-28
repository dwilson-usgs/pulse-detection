# pulse-detection

Matlab codes to detect pulses in broadband data by looking for steps in acceleration.

Contents
======
* PulseAnalysis_test.m  - code to run an example pulse detection run.

* PulseAnalysis_Fn.m - function that detects pulses when passed data in the form of an IRIS webservices data struct

* include folder which contains utilities needed to run.

**External Dependencies:**
 * Matlab with signal processing toolbox
 * irisFetch script and jar file from iris.edu, available here: http://ds.iris.edu/ds/nodes/dmc/software/downloads/irisfetch.m/ and here:
http://ds.iris.edu/ds/nodes/dmc/software/downloads/IRIS-WS/ (last accessed 12/28/2016).

---------------------------------------------------------

**Disclaimer:**

>This software is preliminary or provisional and is subject to revision. It is 
being provided to meet the need for timely best science. The software has not 
received final approval by the U.S. Geological Survey (USGS). No warranty, 
expressed or implied, is made by the USGS or the U.S. Government as to the 
functionality of the software and related material nor shall the fact of release 
constitute any such warranty. The software is provided on the condition that 
neither the USGS nor the U.S. Government shall be held liable for any damages 
resulting from the authorized or unauthorized use of the software.

---------------------------------------------------------