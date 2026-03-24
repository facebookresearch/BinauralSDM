# BinauralSDM

Matlab code to generate binaural RIRs for arbitrary head orientations using the Spatial Decomposition Method [[1]](#references), [[2]](#references) using the BinauralSDM approach with RTMod+AP equalization from [[3]](#references).


## Installation and dependencies

The following dependencies are necessary for the repository to run successfully. Please make sure that they are included in your Matlab search path before executing any demo:

- [SDM Toolbox for Matlab](https://www.mathworks.com/matlabcentral/fileexchange/56663-sdm-toolbox) (must be downloaded manually) - by Sakari Tervo and Jukka Patynen.

- [SOFA API for Matlab](https://github.com/sofacoustics/API_MO) (must be downloaded manually) - by the SOFA conventions team.

- [`getLebedevSphere.m`](ThirdParty/getLebedevSphere.m) (included) - by Robert Parrish.

- [`parfor_progressbar.m`](ThirdParty/parfor_progressbar.m) (included) - by Daniel Terry.

- [`denoise_RIR.m`](ThirdParty/denoise_RIR.m) (included) - by Densil Cabrera and Daniel Ricardo Jimenez Pinilla.

- [Matlab Signal Processing Toolbox](https://www.mathworks.com/products/signal.html) - by Mathworks.

- [Matlab Statistics and Machine Learning Toolbox](https://www.mathworks.com/products/statistics.html) - by Mathworks.

- [Matlab Curve Fitting Toolbox](https://www.mathworks.com/products/curvefitting.html) (for `denoise_RIR.m`) - by Mathworks.

- [Matlab Parallel Computing Toolbox](https://www.mathworks.com/products/parallel-computing.html) (optional, parallelization will be skipped if unavailable) - by Mathworks.


## Demos

Set your Matlab working directory to `./Src/Examples/` to execute the examples:

- [`Demo_BinauralSDM_QuantizedDOA_andRTModAP.m`](Src/Examples/Demo_BinauralSDM_QuantizedDOA_andRTModAP.m)
Generates BRIRs for a multitude of head orientations using the RTMod+AP equalization approach.
To ensure that the example runs, it performs the analysis and synthesis of an example RIR measured with the FRL Array (10 cm diameter) and using TDOA analysis.
The HRIR dataset (Neumann KU100) is downloaded on the fly from the TH Koeln Audio Group server.
This can be easily swapped by any arbitrary HRIR dataset in SOFA format.
This example generated direction dependent early reflections and direction independent late reverberation, after an arbitrary (configurable) mixing time.
The example also includes spatial quantization of the DOA information.
The file can be modified in a straightforward manner to accommodate other analysis and rendering parameters and input data.

More examples will be added in the future, featuring modified decay slopes for reverberation time manipulations, algorithmic late reverberation, and spatial manipulations. 


## Microphone arrays

Files for 3D printing of a microphone array holder (FRL Array) are included in `./Data/ArrayDesigns/`. These are hexahedral arrays (6 DPA 4060) with a center microphone (Earthworks M30/M50) and a diameter of 5 or 10cm.

<img src="./Data/ArrayDesigns/FRLArray_10cmDiameter_pic.jpg" width="200" alt="Depiction of the FRL Array with mounted microphones">

Other array geometries can be accommodated by modifying the file `./Src/create_MicGeometry.m`. The current code also accommodates Tetramic and Eigenmike arrays (with TDoA estimation) but we recommend to not use them (see [[3]](#references) for details and justification).


## Citing BinauralSDM

If you use this code in your research, please cite the following [paper](https://www.aes.org/e-lib/browse.cfm?elib=21010):
```
@article{amengual20BSDM,
  title     =     {Optimizations of the Spatial Decomposition Method for Binaural Reproduction,
  author    =     {Sebastia V. Amengual Gari and Johannes Arend and Paul Calamia and Philip Robinson},
  journal   =     {Journal of the Audio Engineering Society},
  volume    =     {68},
  number    = 	  {12},
  pages     =     {959 -- 976},
  doi       =     {https://doi.org/10.17743/jaes.2020.0063}
  month     =     {12}
  year      =     {2020}
}
```


## References

[[1]](http://www.aes.org/e-lib/browse.cfm?elib=16664) S. Tervo, J. Patynen, A. Kuusinen, and T. Lokki, “Spatial Decomposition Method for Room Impulse Responses,” J. Audio Eng. Soc., vol. 61, no. 1/2, pp. 17–28 (2013 Jan.).

[[2]](https://doi.org/10.17743/jaes.2015.0080) S. Tervo, J. Patynen, N. Kaplanis, M. Lydolf, S. Bech, and T. Lokki, “Spatial Analysis and Synthesis of Car Audio System and Car Cabin Acoustics With a Compact Microphone Array,” J. Audio Eng. Soc., vol. 63, no. 11, pp. 914–925 (2015 Nov.), https://doi.org/10.17743/jaes.2015.0080.

[[3]](https://doi.org/10.17743/jaes.2020.0063) S. V. Amengual Gari, J. Arend, P. Calamia, P. Robinson, “Optimizations of the Spatial Decomposition Method for Binaural Reproduction,” J. Audio Eng. Soc., vol. 68, no. 12, pp. 959-976 (2020 Dec.), https://doi.org/10.17743/jaes.2020.0063.


## Changelog

### 2022-08-30 - v0.5
- Add `Save_BRIR_sofa.m` to export rendered BRIRs as SOFA-file (activated by default over exporting individual WAV-files with according changes for new flags in `create_BRIR_data.m`)
- Rename `SaveBRIR.m` into `Save_BRIR_wav.m`
- Add `Initialize_SOFA.m` to extract functionality from `Read_HRTF.m` to be reusable
- Remove and add `Align_DOA.m` and `Split_BRIR.m` to fix git capitalization issues

### 2022-04-07
*This update introduces changes to the names and parametrisation of internal functions which may break compatibility to code using former versions of this toolbox. When applying the method it is therefore strongly advised to start by applying individually required modifications to the provided [Demo](#demos). The script has been improved in terms of documentation, variable naming, logging verbosity, plot generation and data export.*
- Update `README.md` with improved formatting, links to publications and changelog
- Update all functions to be more verbose by cleaning up and adding logging messages
- Update all function headers to follow consistent parameter documentation (e.g. `create_BRIR_data.m` and `create_SRIR_data.m`)
- Update all functions to follow consistent code formatting
- Rename function names to follow a more consistent convention:
  - `align_DOA.m` -> `Align_DOA.m`
  - `ModifyReverbSlope.m` -> `Modify_Reverb_Slope.m`
  - `removeInitialDelay.m` -> `Remove_BRIR_Delay.m`
  - `split_BRIR.m` -> `Split_BRIR.m`
- Update `Align_DOA.m` to use the beforehand estimated DOA of direct sound instead of averaging again (the former implementation as well as other methods are documented in the function)
- Add `Apply_Allpass.m` to extract functionality from `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m` for modifying late reverberation
- Update `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m` to skip downloading HRTF if already present
- Update `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m` to use adjustable sampling frequency for allpass filters
- Update `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m` to skip redundant exports of late reverberation
- Update `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m` to generate verbose plots for all analysis, processing and export steps
- Update `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m` to provide user-defined DOA rotation before DOA quantization
- Update `Modify_Reverb_Slope.m` to provide experimental RTmod regularization (deactivated by default)
- Add `Plot_BRIR.m` to generate and export a plot of a BRIR in (0, 0) deg direction
- Add `Plot_DOA.m` to generate and export a plot of SDM DOAs after SRIR analysis
- Add `Plot_Spec.m` to generate and export a plot of SDM spectra after SRIR analysis
- Update `PreProcess_P_RIR.m` to skip denoising if the Matlab Curve Fitting Toolbox is unavailable 
- Update `PreProcess_Synthesize_SDM_Binaural.m` and `Synthesize_SDM_Binaural.m` to stack left and right HRIRs in single variable 
- Update `Read_HRTF.m` to give instructions if the SOFA API is unavailable 
- Add `Rotate_DOA.m` extracting functionality used in `align_DOA.m` and `Synthesize_SDM_Binaural.m`
- Update `SaveBRIR.m` to make export of combined and separate direct sound and early reflection optional
- Update `Synthesize_SDM_Binaural.m` to remove default specification of target BRIR length
- Update `create_BRIR_data.m` to provide additional options for reverberation equalisation process
- Add `roty.m` and `rotz.m` to eliminate dependency for Phased Array System Toolbox

### 2021-11-17 - v0.1
*This update allows the user to specify two new fields in BRIR_data:</br>
**BRIR_data.BandsPerOctave:** Specifies the frequency resolution for the reverb equalization. The values can be 1 or 3. For smaller rooms, 1 is recommended. By default it is 3.</br>
**BRIR_data.EqTxx:** To perform reverb equalization, the RT60 must be estimated. However, there is generally not enough SNR to obtain a true T60 estimation. This parameter allows the user to specify the desired Txx for the RT60 estimation. Generally, a value of 30 is recommended. However, this can blow up the RT estimation in cases where SNR is low. For small rooms and very dry spaces we recommend using a value of 20. By default it is 30.*
- Update `Demo_BinauralSDM_QuantizedDOA_andRTModAP.m`, `GetReverbTime.m`, `ModifyReverbSlope.m` `PreProcess_Synthesize_SDM_Binaural.m`, `getLundebyFOB.m` and `getLundebyRT30.m` with mew equalization options to make reverberation equalisation process more robust
- Update `create_BRIR_data.m` and `PreProcess_Synthesize_SDM_Binaural.m` to provide additional options for reverberation equalisation process
- Update `Read_HRTF.m` to fix loading of FRL HRTFs
- Update `create_FIR_eq.m` to use linear instead of cubic interpolation
- Update `create_MicGeometry.m` to add custom FRL array
- Update `SaveBRIR.m`, `SaveRenderingStructs.m` and `create_SRIR_data.m` to add custom path
- Update `read_RIR.m` to perform if sampling frequencies are mismatched


## Contributing

See the [CONTRIBUTING](CONTRIBUTING.md) file for how to help out.


## License

BinauralSDM is CC-BY-4.0 licensed, as found in the [LICENSE](LICENSE) file.


## Contact

Sebastia V. Amengual (samengual@fb.com)

Philip Robinson (philrob22@fb.com)
