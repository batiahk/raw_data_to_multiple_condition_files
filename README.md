# raw_data_to_multiple_condition_files
Creating multiple_conditions files for statistic analysis of fMRI data in SPM 

1) Parse raw data in experiment output files (run1, run2 and run3)
2) Find subject codes (ID)
3) extract the onsets of the various experimental conditions from the columns of data
4) create multiple_condition files containing the condition names, their onsets and their durations
in accordance with the format required for analysis in SPM12
5) Create a file for each of the the 3 sessions for each of the 39 subjects
6) save under subject serial_codes to facilitate iteration in later analyses
7) correct typos and missing codes in raw output so that the files contain the corrected codes
