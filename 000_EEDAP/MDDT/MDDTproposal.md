=Product Description=

eeDAP is being proposed as an MDDT for Clinical Outcome Assessments (COA). 
eeDAP is an evaluation environment for digital and analog pathology. eeDAP is 
a software and hardware platform for designing and executing digital and 
analog (microscope) pathology studies where the digital image is registered 
to the real-time view of the corresponding glass slide on the microscope. 
This registration allows for different pathologists to evaluate the same 
fields of view (FOVs) in digital mode or in microscope mode. Consequently, it 
is possible to reduce or eliminate a large source of variability in comparing 
these modalities in the hands of the pathologist: the FOVs (the tissue) being 
evaluated. In fact, the current registration precision of eeDAP allows for 
the evaluation of the same individual cell in both domains. As such, a study 
can be designed where pathologists are asked to evaluate a preselected list 
of individual cells or specific FOVs in the digital mode and with the 
microscope. Consequently, paired observations from coregistered FOVs are 
collected allowing for a tight comparison between WSI and optical microscopy. 

A reader study with eeDAP is intended to evaluate the scanned image, not the 
clinical workflow of a pathologist or lab. Instead of recording a typical 
pathology report, eeDAP enables the collection of explicit evaluation 
responses (formatted data) from the pathologist corresponding to very narrow 
tasks. This approach removes the ambiguity related to the range of language 
and the scope that different pathologists use in their reports.

Reader studies utilizing eeDAP are meant to focus on tasks related to 
specific histopathology features. Since certain image features can challenge 
image quality properties (color fidelity, focus quality, and depth of field), 
reader studies with tasks based on features can provide valuable information 
for the assessment of WSI and its role in clinical practice. eeDAP allows for 
the formulation of different types of tasks, many of which are currently 
available in eeDAP: free-text, integer input for counting tasks, a slider in 
a predefined range for a confidence scoring task (ROC task, receiver 
operating characteristic task), check boxes of specific categories for a 
classification task, and marking the image for a search task. These simple 
tasks can be customized with moderate MATLAB programming skills to suit the 
study's purposes.

In what follows, we provide a quick summary of the hardware and software. 
More details can be found in Reference 1. 

The eeDAP hardware includes a microscope with a camera (mounted for 
simultaneous viewing with the eyepiece), a motorized stage (programmable with 
a stage controller and joystick), and computer as shown in Figure 1. There is 
also a reticle in the eyepiece with cross hairs or rectangles that is needed 
for registration and for defining evaluation regions. eeDAP can support usb 
and FireWire (IEEE 1394) cameras. The camera pixel sizes tested are smaller 
than 10um. At 40x magnification, this corresponds to camera resolutions 
better than 0.25 um/pixel. Regarding the motorized stage, eeDAP supports 
communications with Ludl and Prior stages. The step size for the stages 
tested are smaller than 0.1 um. 

For the cameras and stages tested, we are able to repeatably and reliably 
register the WSI image and the glass slide so that the pathologists can 
evaluate the same FOVs in both modes. 

[[Image(hardware_label.png)]]

The eeDAP software is made up of graphical user interfaces (GUIs) written in 
MATLAB (Mathworks, Natick, Massachusetts). Using eeDAP does not require a 
full licensed version of MATLAB. It can be run as a precompiled stand-alone 
application. The precompiled stand-alone application requires that the free 
MATLAB compiler runtime (MCR) library be installed ^1^. The software uses the 
Bioformat library to read WSI images and extract FOVs. It supports several 
formats of WSI image such as svs, ndip and tiff. Normally the resolution of 
40x WSI images is about 0.5 or 0.25 um/pixel. 

The eeDAP supports two modes of reading, Digital and Micro_RT. Digital mode 
uses a set of regions of interest (ROIs) identified and extracted from WSIs. 
In Micro_RT mode, the system does registration between WSI and glass slide. 
With registration, the system offers the reader a real-time view of the 
identical set of the same ROIs from a glass slide, through the optics of a 
microscope. In other words, the two modes are registered to one another. 
Furthermore this tool allows for the administrator of the study to have a 
high level of control over the format of the tasks presented to the readers 
through specifications in an input file. Several simple default tasks are 
available to the administrator: multiple choice, continuous sliders, or 
binary responses as Figure 2. 

[[Image(software_label.png)]]


[[BR]] 

=Context of Use= ''1) The device or product area for which the MDDT is 
qualified''[[br]] Digital pathology (DP) incorporates the acquisition, 
management, and interpretation of pathology information generated from a 
digitized glass slide. DP is enabled by technological advances in whole slide 
imaging (WSI) systems, also known as virtual microscopy systems, which can 
digitize whole slides at microscopic resolution in a short period of time^1^. 
The main objective of WSI system is to build digital slides with high 
magnifications^2^. The imaging chain of a WSI system consists of multiple 
components including the light source, optics, motorized stage, and a sensor 
for image acquisition. WSI systems also have embedded software for 
identifying tissue on the slide, auto-focusing, selecting and combining 
different fields of view (FOVs) in a composite image, and image processing 
(color management, image compression, etc.). Details regarding the components 
of WSI systems can be found in Gu and Ogilvie^3^.[[br]] __Q for WSI group: We 
hope to get background, introduction and meaning about Digital pathology, WSI 
and devices.__ 

''2) The stage(s) of device development (e.g., early feasibility study, 
pivotal study, etc.)''[[br]] In the United States, WSI device is available in 
market for researching and education, but it has not been approved for 
clinical usage. However, it got the clinical approval in some other countries 
such as Canada, Sweden several years ago. And recently, it got the approval 
in The UK and Ireland. [[br]] __Q for WSI group and manufacture: We hope to 
get more information about development stage of DP, WSI. For example several 
big countries’ development stage and when did they approved the stage.__ 

''3) The specific role of the MDDT (for clinical uses this includes the study 
population or disease characteristics, as well as specific use – diagnosis, 
patient selection, clinical endpoints)."[[br]] The eeDAP is proposed as an 
MDDT for evaluating WSI performance and collecting labels for training image 
analysis programs. 

''4) How to use MDDT in regulatory context''[[br]] The eeDAP is proposed as 
an MDDT for the context of use measuring and evaluating quantity of WSI. It 
is used to collect pathologists’ evaluations for the same FOV’s on WSI 
(Digital Mode) and glass slide (MicroRT Mode), at the same time asks expert 
to do some tasks about the ROIs. The measurement and evaluation of quantity 
of WSI are based on the similarity our two modes results. 


[[BR]] 

=Strength of Evidence=
 * '''Tool Validity.''' Does the available data adequately support the validity
of the measurement? Does the MDDT measure reliably and accurately? Depending 
on the tool type, this may include analytical, clinical, and construct 
validity, sensitivity, specificity, accuracy, precision, repeatability, 
external validity, reduction of bias, verification of the constitutive model, 
uncertainty quantification, numerical convergence, etc. 
 * ''' Plausibility.''' Is it scientifically plausible that the measurements
 obtained through use of the MDDT are related to the true outcome of interest?
 Is there a causal path or mechanistic explanation to connect the MDDT to the
 outcome?
 * '''Extent of Prediction.''' What data are available to demonstrate a
 predictive relationship between the MDDT and the true outcome of interest?
 What is the strength of that predictive relationship? Is the prediction
 repeatedly demonstrated in multiple studies or as a class effect? If relevant,
 is the conclusion (that the effect of treatment on the measurement obtained
 using the MDDT predicts the outcome of interest) supported by credible
 information?
 * '''Capture.''' Does the MDDT fully capture the aggregate effect of the
 intervention on the true outcome of interest? Does the MDDT account for every
 major effect of the intervention? Are there available data which call this
 into question?

===Plan for get data ===

======1. Registration quality  ''(Tool Validity)''======
Create new task in eeDAP to test it. 
  * Question: When does registration succeed?
  * Options: A. Automatically B. After focus and fast registration. C.
After best registration. D. Fail.
  * Measurement: Whether the center of reticle is inside target cell.
======2.  Color display quality ''(Tool Validity)''======
 Apply Image ICC and manufacture viewer software ICC to eeDAP (base on Bioformat).[[br]]
 Measure the output signal from cable for eeDAP WSI and manufacture viewer software WSI.
__Q for Manufacture: We need viewer software ICC and application method to process our extracted WSI image.__
======3.  Study results ''(Capture)''======
 Complements NIH mitotic counting study
  * Calculate the reader agreement (bias and correlation).[[br]]
__Q for NIH: We hope to get all mitotic figure counting data (ROIs, results).__ [[br]]
__Q for WSI group: We hope to find experts from the group to do mitotic figure counting.__  

[[BR]] 

=Assessment of Advantages and Disadvantages=
===Advantages:===
======1.  Eliminates location variability======
           The eeDAP system can help experts read exact same ROIs on WSI and a glass slide.
======2.  Reading efficiency======
          After one time registration between WSI and glass slide, all ROIs on this specimen moving is automatic. 
======3.  Results collecting and analyzing======
          Output report includes all study settings and results in a neat format.
======4.  Customizable======
          Users can create new kinds of task if they do Matlab program.     

===Disadvantages:===
======1.  Not the native viewer======
          The eeDAP is WSI image is extract and display by Bioformat and Matlab bur not manufacture viewer software. The influence can be reduced by applying ICC.
======2.  Current not pan and zoom======
          Currently, user can’t pan and zoom WSI in eeDAP. 
======3.  Lack of global view======
          Currently, all existing tasks are based on FOV not whole slide.

[[BR]] 

=Consent to Public Disclosure and Use=
The compiled eeDAP software and all source codes are shared on Github with HTML and PDF versions manuals. The video version manual is under processing.  The only prerequisite software for compiled eeDAP software is MATLAB compiler runtime, which is free to download and use. These guarantee (1) FDA can make public sufficient information to support use of the qualified eeDAP and (2) the general public can use the eeDAP and rely on data generated using the eeDAP in gaining FDA clearance or approval of other devices.

[[BR]] 

=References=
 1.	B. D. Gallas et al. “Evaluation Environment for Digital and Analog Pathology: A Platform for Validation Studies.” Journal of Medical Imaging 1.3 (2014).
 2.	M. G. Rojo et la. "Critical Comparison of 31 Commercially Available Digital Slide Systems in Pathology." International Journal of Surgical Pathology, 14(4), 285-305. (2006).
 3.	J. Gu and R. W. Ogilvie, Eds., Virtual Microscopy and Virtual Slides in Teaching, Diagnosis, and Research, CRC Press, Boca Raton, Florida (2005).
