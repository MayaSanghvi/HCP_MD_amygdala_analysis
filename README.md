# HCP_MD_amygdala_analysis
This mix of Python and MATLAB code allows the user to replicate findings from the paper: "Disentangling the Neural Dynamics of Cognitive and Emotional Processing During Movie Watching"

**How you can get started with the project**
There are five main components of this project. The four folders are all somewhat independent, but use of the first component will be very helpful in using the rest. 

1. **HCPmovieData_Windows30.m**: This MATLAB code contains a lot of info. In order to use it, you will need to have access to the HCP movie runs and change all the directories to point to places on your machine (currently they work for mine). Once you have directed the code properly, the code should produce correlation matrices with two chosen ROIs, timecourses with a specified number of points of high and low activation pulled out, and a plot of correlated and anticorrelated activation scenes for the two ROIs. It can also save chunks of the movies to your outdir. 

2. **emotion_data folder**: This folder contains the z-scored and concatenaed emotion label data from the 16 raters, split by portrayed and viewer emotions. There are two Python scripts here, one which first does a PCA on the emotion ratings and then checks inter-rater reliability with SB correction. The second script uses the output from the PCA to run t-tests on the PCs for the peaks and troughs of activity in the ROIs and create bar graphs of the results.

3. **face_data folder**: This folder has the raw face annotation data, which was annotated by Python's RetinaFace. There is MATLAB script that, if you have run the HCPmovieData script and saved clips out, can pull the relevant time points into a new CSV on which you can do stats, per the Python file. If you don't want to do this step and just want to run the same stats I did in the paper, the folder also contains a csv of the relevant scenes labeled for presence of face, number of faces, and area taken up by face. Finally, Python the code allows you to do a t-test between the peaks and troughs of the two ROIs, and creates bar graphs of the results. 

4. **sound_data folder**: This folder has the raw sound annotation data, which was created with MATLAB's classifySound function. Just as with the face data, there is MATLAB script that, if you have run the HCPmovieData script and saved clips out, can pull the relevant time points into a new CSV on which you can do stats, per the Python file. If you don't want to do this step and just want to run the same stats I did in the paper, the folder also contains a csv of the relevant scenes labeled with each of the sounds as present or not for each of the six seconds. Finally, the Python code allows you to do a t-test between the peaks and troughs of the two ROIs, and creates bar graphs of the results.

5. **MANOVA**: Here you can find a csv that contains all the emotion, face, and sound data concatenated into one dataframe, as well as Python code that runs a multivariate analysis of variance test on the data. 

**Where users can get help with your project**
Have you noticed something off? Is the code not running? Feel free to reach out to me at my email:
mayaDOTbDOTsanghviATgmailDOTcom
