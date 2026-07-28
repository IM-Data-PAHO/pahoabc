# PAHOabc <img src="man/figures/logo.png" align="right" height="138" />

> 🌐 [**Lea esto en español**](https://im-data-paho.github.io/pahoabc/README.es.html)

PAHOabc is an R package aimed at immunization (A)nalyses (B)eyond (C)overage. 

PAHOabc aims to support the Pan American Health Organization's (PAHO) Comprehensive Immunization Unit (CIM) mission by providing advanced data analysis tools for immunization programs in the Americas. Specifically, it facilitates the calculation of innovative indicators beyond basic coverage, supports evidence-based decision-making through in-depth data exploration and visualization, and contributes to strengthening data capabilities within immunization programs by empowering human resources to effectively leverage their data.

To learn more about PAHO's work on immunization, visit the [PAHO Immunization site](https://www.paho.org/en/topics/immunization).

For documentation and vignettes for this R package, see: [https://im-data-paho.github.io/pahoabc](https://im-data-paho.github.io/pahoabc).

## Installation

```r
# Install from GitHub
devtools::install_github("IM-Data-PAHO/pahoabc")
```

## Usage

Currently, PAHOabc contains six main modules. Follow the links below to explore detailed vignettes with practical examples and guidance on how to use each module:

1. [**Nominal Dropout Rate**](https://im-data-paho.github.io/pahoabc/articles/en/nominal_dropout_en.html)  
   Calculates dropout rates between any two vaccine doses using nominal data. This module ensures accurate follow-up tracking across a vaccination schedule.

2. [**Residence vs. Occurrence Analyses**](https://im-data-paho.github.io/pahoabc/articles/en/residence_occurrence_en.html)  
   Functions for comparing vaccination coverage and dose distribution based on where people live versus where they were vaccinated. This module helps identify population movement and service coverage gaps across geographic areas.

3. [**Complete Schedule Coverage**](https://im-data-paho.github.io/pahoabc/articles/en/complete_schedule_en.html)  
   Evaluates whether individuals have received all required doses in a national immunization schedule (for a specific cohort up to a specified age). This module differs from standard coverage calculation as it evaluates each individual's compliance of the national immunization schedule.

4. [**Birth Cohort Coverage**](https://im-data-paho.github.io/pahoabc/articles/en/birth_cohort_coverage_en.html)  
   Lets users track and visualize vaccination status among a specific cohort of newborns. Helps evaluate population-level protection against vaccine-preventable diseases.

5. [**Date Consistency Comparison**](https://im-data-paho.github.io/pahoabc/articles/en/date_consistency_comparison_en.html)  
   Identifies and quantifies logical inconsistencies between any two date variables in the EIR (e.g., vaccination date before date of birth). Helps detect data entry errors and record linkage issues before downstream analyses.

6. [**Eligibility Consistency Comparison**](https://im-data-paho.github.io/pahoabc/articles/en/eligibility_consistency_comparison_en.html)  
   Identifies and quantifies whether vaccination events occurred within the age window defined by the national immunization schedule. Helps detect ineligible doses administered too early or too late, pointing to service delivery timeliness issues.

Each module works seamlessly with the example datasets provided in the package. These examples make it easy to test out the functionality and serve as a reference when preparing your own data. Learn more about these example datasets [in this vignette](https://im-data-paho.github.io/pahoabc/articles/en/example_datasets_en.html).

> **Note**
> 
> You can explore all the available vignettes by clicking on the **Guides** button in the navigation bar.

## Contribute

We welcome suggestions, bug reports, and feature requests through the [GitHub Issues](https://github.com/IM-Data-PAHO/pahoabc/issues) page. If you'd like to contribute code or fixes, feel free to open a [pull request](https://github.com/IM-Data-PAHO/pahoabc/pulls). 
