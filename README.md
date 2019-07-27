# Voltage imaging analysis
This code is for importing series of tiff stack images and extracting time profiles of fluorescence intensity from multiple manually drawn ROIs using a graphic user interface. The profile is then corrected for camera noise, interpolated and bleach corrected using an exponential fit. The parameters of the voltage signals are then measured. In this case, the expected signal is time-locked trains of action potentials, and each of the signals to be analysed is selected using a graphic user interface. The average trace,the amplitude, width, rise and decay time, decay fin and signal to noise ratio are outputted.

A version of this code was used for analysis of voltage traces in the preprint "Homeostatic plasticity rules control the wiring of axo-axonic synapses at the axon initial segment" by Pan-Vazquez et al.: https://www.biorxiv.org/content/10.1101/453753v2 

![example_steps](/images/example_steps.png)
