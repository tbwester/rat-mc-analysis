# RAT MC Analysis

Get a confidence interval for the simulated GQE value & make some plots

## Setup

### ROOT Plots

- Get the [ratpac-nudot repository](https://github.com/tbwester/ratpac-nudot)
- Switch to the "param" branch
- Run `python random_parameters.py x` to generate some new parameters
- Run rat: `bo_total_autorun.sh run1 new`
- Zip up the files in the `output/run1` directory to `run1.tar.gz`
- Make a `data/` folder in this repository. Move the tar.gz file into it.
- Now run `./analyze.sh` to generate a root plot. Make many tar.gz files to add more data

### R Confidence Interval (do ROOT plots first)

- Do `python random_parameters.py n 1000` in ratpc-nudot repository to generate 1000 sets of parameters (paramlist.txt)
- Do `python random_parameters.py r 10` to load the 10th set, etc.
- Run rat as above, match the "run#" argument to the parameter set (0-based)
- Copy all zip files over to `data/` directory as before.
- The output of `./analyze.sh` should be put in a text file in r/peaks.txt
- Copy generated paramlist.txt file to r/paramlist.txt
- Do `python random_parameters.py d` to get a list of parameter defaults. Copy this to r/default_parameters.txt
- `Rscript param_analyze.R`
