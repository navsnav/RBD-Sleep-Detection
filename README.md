[![license](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](./LICENSE)


## Sleep Staging and RBD Detection
#### Code used in paper: Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis

When using this code, please cite [our paper](**provide link**): 

> Navin Cooray, Fernando Andreotti, Christine Lo, Mkael Symmonds, Michele T.M. Hu, & Maarten De Vos (in review). Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis. Clinical Neurophysiology.

This repository contains the tools to extract 130 features from a single EEG, EOG and EMG signal over 30s epochs. 

A random forest classifier is provided to achieve automatic sleep staging, which was trained using 53 age-matched healthy control and RBD participants (but only with 50 trees, wheras the paper used 500). A classifier can also be trained using this repository. Classifier should output one of the following sleep stages:

| Class  | Description |
| ----- | -------------------:|
| 0 | Wake |
| 1 | N1 |
| 2 | N2 |
| 3 | N3 |
| 5 | REM |

An additional feature extraction tool is provided to analyse a single EMG channel for RBD detection. Features are derived for each subject and include established RBD metrics as well as additional metrics. These features can be derived using manually annotated or automatically classified sleep stages. 

An additional random forest classifier is provided to achieve RBD detection using RBD metrics, which was trained using 53 age-matched healthy control and RBD participants. A classifier can also be trained using this repository. Classifier should output one of the following states:

| Class  | Description |
| ----- | -------------------:|
| 0 | Healthy Control |
| 1 | Potential RBD Individual |

* Matlab Random Forest Model - Sleep Staging (`data` folder)
* Matlab Random Forest Model - RBD Detection  (`data` folder)

## Downloading data

Example PSG data can be downloaded from physionet [The CAPS Sleep Database](https://physionet.org/pn6/capslpdb/). Alternatively the main files include code to download sample files from physionet (5 healthy controls and 5 RBD participants). Lastly, code can be modified to point to a folder containing necessary raw files or mat files. 

## Acknowledgment
All authors are affiliated at the Institute of Biomedical Engineering, Department of Engineering Science, University of Oxford.

## License

Released under the GNU General Public License v3

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

## References

When using this code, please cite [1].

[1]:Navin Cooray, Fernando Andreotti, Christine Lo, Mkael Symmonds, Michele T.M. Hu, & Maarten De Vos (Review). Detection of REM Sleep Behaviour Disorder by Automated Polysomnography Analysis. Clinical Neurophysiology.
