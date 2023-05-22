# CommunicativeStateClassification
This algorithm takes audio waveforms from 2-4 talkers and classifies the communicative state onsets, offsets and durations.
The first step is to perform Voice Activity Detection (VAD) on the raw audio files, and the next is to feed the binary activity array into the Communicative State Classification (CSC) algorithm.

`tutorial/tutorial_CSC.m` will guide you through how to run the VAD and CSC, based on the functions in the _tools_ folder, on an example of a conversation taken from Sørensen, Anna Josefine, Fereczkowski, Michal, & MacDonald, Ewen Neale. (2018, March 21). "Task dialog by native-Danish talkers in Danish and English in both quiet and noise." Zenodo. https://doi.org/10.5281/zenodo.1204951

For an overview of the nomenclature, please refer to my PhD thesis: Sørensen, A. Josefine Munch. 2021. "The Effects of Noise and Hearing Loss on Conversational Dynamics." DTU Health Technology. https://findit.dtu.dk/en/catalog/615d73b4d9001d0143799332, specifically Figure 2.2. on p. 18.

NB! The functions `determineStartCH.m` and `channelTurn.m` need the `bi2de` and `de2bi` functions from the _Communications Toolbox_ in MATLAB. If you do not have access to that toolbox, you need to write a function that converts a decimal to a binary array and vice versa. In a future commit, these functions will be added to the _tools_ folder.

For questions, please contact me at annajosefine@gmail.com.
