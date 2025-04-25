# PAHOabc <img src="man/figures/logo.png" align="right" height="138" />

PAHOabc is an R package aimed at immunization (A)nalyses (B)eyond (C)overage. 

PAHOabc aims to support the Pan American Health Organization's (PAHO) Comprehensive Immunization Unit (CIM) mission by providing advanced data analysis tools for immunization programs in the Americas. Specifically, it facilitates the calculation of innovative indicators beyond basic coverage, supports evidence-based decision-making through in-depth data exploration and visualization, and contributes to strengthening data capabilities within immunization programs by empowering human resources to effectively leverage their data.

For documentation and vignettes, see: [https://im-data-paho.github.io/pahoabc](https://im-data-paho.github.io/pahoabc).

## Installation

```r
# Install from GitHub
devtools::install_github("IM-Data-PAHO/pahoabc")
```

## Usage

Currently, PAHOabc contains three main modules. Follow the links below to explore detailed vignettes with practical examples and guidance on how to use each module:

1. [**Nominal Dropout Rate**](https://im-data-paho.github.io/pahoabc/articles/nominal_dropout_en.html)  
   Calculates dropout rates between any two vaccine doses using nominal data. This module ensures accurate follow-up tracking across a vaccination schedule.

2. [**Residence vs. Occurrence Analyses**](https://im-data-paho.github.io/pahoabc/articles/residence_occurrence_en.html)  
   Functions for comparing vaccination coverage and dose distribution based on where people live versus where they were vaccinated. This module helps identify population movement and service coverage gaps across geographic areas.

3. [**Complete Schedule Coverage**](https://im-data-paho.github.io/pahoabc/articles/complete_schedule_en.html)  
   Evaluates whether individuals have received all required doses in a national immunization schedule (for a specific cohort up to a specified age). This module differs from standard coverage calculation as it evaluates each individual's compliance of the national immunization schedule.

Each module works seamlessly with the example datasets provided in the package. These examples make it easy to test out the functionality and serve as a reference when preparing your own data. Learn more about these example datasets [in this vignette](https://im-data-paho.github.io/pahoabc/articles/example_datasets_en.html).

> **Note**
> 
> You can explore all the available vignettes by clicking on the **Guides** button in the navigation bar.

## Contribute

We welcome suggestions, bug reports, and feature requests through the [GitHub Issues](https://github.com/IM-Data-PAHO/pahoabc/issues) page. If you'd like to contribute code or fixes, feel free to open a [pull request](https://github.com/IM-Data-PAHO/pahoabc/pulls). 
