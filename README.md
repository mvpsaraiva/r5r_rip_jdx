## r5r_rip_jdx
Tests to compare r5r results with and without the `jdx` package

Instructions:

### - with jdx

Install r5r 0.6-0 from GitHub master branch and run first script:

```R
remove.packages("r5r")
devtools::install_github("ipeaGIT/r5r", subdir = "r-package")
source("R/r5r_jdx.R")
```

### - without jdx


Install r5r 0.6-0 from GitHub dev branch and run second script:

```R
remove.packages("r5r")
devtools::install_github("ipeaGIT/r5r", subdir = "r-package", ref = "dev")
source("R/r5r_java_to_dt.R.R")
```

### check the difference

Check if there's any difference in the results using the `R/compare.R` script

