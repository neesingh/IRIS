Indiana Retinal Image Simulator
Created by Larry Thibos et al. Developed by Matt Jaskulski.
Indiana University School of Optometry
Copyright 2019

***********************************************************
Thank you for downloading IRIS! This program is a collaborate effect of many years of work of numerous researchers initiated by prof. Larry Thibos at Indiana University.

It is a research tool, however the Authors hope that it will also be of interests to students from fields like physiological optics, vision, optometry, and others. We hope that a simple user interface and accurate graphics can vividly illustrate the characteristics of ocular aberrations and their impact
 on retinal image quality through point spread functions and retinal simulations.

***********************************************************

You are free to use this software for research and academic purposes under the condition that you provide the following reference:

Jaskulski M, Thibos L, Bradley A, et al. IRIS - Indiana Retinal Image Simulator. 2018; http://blogs.iu.edu/corl/iris.

This software is released under the following license:
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International Public License
Please see license.txt for more information or go to https://creativecommons.org/licenses/by-nc-nd/4.0/

***********************************************************
I. Requirements

	1. A PC or Mac running Matlab 2015a or more recent (2018b recommended).
	2. A display with at least 1600 x 900 pixels (1920 x 1080 recommended).
	3. Certain understanding of optical aberrations, wavefronts and optics. 

***********************************************************
II. Installation

	1. Download the installation package from http://blogs.iu.edu/corl/iris
	2. Uninstall any previous version of IRIS.
	3. Extract the archive and launch IRIS installer.exe.
		This will download the required Matlab dependencies from MathWorks (approximately 800 Mb).
	4. After the installation is complete, run the program by double clicking on the blue "IRIS" icon.


***********************************************************
III. Features

	1. Input data formats:
		- F4, F6, F8, F10	- Wavefront Sciences COAS.
		- DAT			- ImagineOptic HASO.
		- TXT			- ImagineOptic IRX3.
		- CSV			- Nidek OPD Scan III.
		- MAT			- IRIS's own, previously saved data.
		- Manual data entry.

	2. Output data formats:
		IRIS allows users to save certain results of carried-out analyses either
		as images (PNG, JPG) or as plain-text data copied to the clipboard which
		can then be pasted into Excel or any other program.
		Additionally IRIS can save complete analyses results into MAT files.

	3. Analysis capabilities
		Work with IRIS starts by inputting ocular aberrations espressed as Zernike
		coefficients using one of the supported data formats. Subsequently the
		following capabilities become available:
		- Computing optometric parameters: cylinder, sphere, axis, power vectors,
		  minRMS, paraxial, MTR spherical equivalents, etc.
		- Performing both single and through-Zernike analyses of image quality, in
		  particular through-Focus analyses. 
		- Computing Fourier and geometrical optics Point-Spread-Functions (PSFs).
		- Evaluating image quality with numerous objective refraction metrics.
		- Performing polychromatic simulations taking into account the longitudinal
		  chromatic aberration (LCA), human spectral sensitivity curve (Vlambda) and
		  spectral power distribution (SPD) of a source.
		- Simulate effects of different pupil shapes and sizes and effects of pupil
		  masking (for example due to cataract).
		- Computing and plotting detailed wavefront-derived functions such as vergence,
		  curvature and slope and also the modulation transfer function (MTF).
 		- and more... please refer to the changelog.txt for more information.

IV. Contact and Support

IRIS is available to download for free exclusively via the IU Clinical Optics Research Lab website (http://blogs.iu.edu/corl/iris). If you have questions or feedback (which is very welcome!) please use the comment form therein rather than trying to reach the Authors directly.
The exception would be research collaborations - if you are a researcher or a Masters/PhD-degree student and wish to collaborate with us and use IRIS.

V. Ackgnowledgements

Contributors: Sowmya Ravikumar (polychromatic PSF algorithms), Jos Rozema (statistical wavefront generator), Linda Lundström (Zernike rescaling algorithms), and others.
Special Thanks to: Norberto López Gil, Arthur Bradley, Pete Kollbaum, D. Robert Iskander, Iván Marin-Franch, Miguel Faria Ribeiro.

V. Disclaimer
THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.











