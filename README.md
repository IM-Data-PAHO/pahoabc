# PAHOabc <img src="man/figures/logo.png" align="right" height="138" />

PAHOabc is an R package aimed at immunization (A)nalyses (B)eyond (C)overage. For documentation and vignettes, see: [https://im-data-paho.github.io/pahoabc](https://im-data-paho.github.io/pahoabc).

## Introduction

The Special Program Comprehensive Immunization (CIM) at the Pan American Health Organization (PAHO) seeks to promote and coordinate technical cooperation and partnerships to support Member States' efforts to sustainably and equitably reduce morbidity and mortality from vaccine-preventable diseases (VPDs) through control and elimination strategies to improve the quality of life and life expectancy of the peoples of the Americas.

For over 40 years, the success of the Expanded Program on Immunization (EPI) has made the Region of the Americas a global leader in the elimination and control of VPDs, such as smallpox, polio, rubella, congenital rubella syndrome, measles, and neonatal tetanus. Since the creation of the EPI in 1977, countries have moved from using six vaccines in their national vaccination schemes, to an average of more than 16 vaccines, which represent greater protection for the population.

Within the framework of the resolution "Reinvigorating immunization as a public good for universal health" approved in 2021 by PAHO's governing bodies, CIM seeks to revitalize immunization programs in Member States by implementing innovative approaches and best practices through six lines of action:

1. Strengthen governance, leadership and financing of immunization programs.
2. Improve immunization coverage monitoring and surveillance by incorporating digital intelligence strategies into routine analysis.
3. Strengthen the integration of immunization programs into the primary health care system toward universal health.
4. Develop innovative and strategic communication approaches to build social awareness and trust in vaccines and increase access to services.
5. Strengthening human resource capacities for immunization programs.
6. Using scientific evidence to guide decision making and program delivery.

### How does PAHOabc respond to these lines of action?

The PAHOabc R package is designed to support PAHO/CIM's mission by providing advanced data analysis tools to strengthen immunization programs across the Americas. Aligned with CIM's strategic action lines, this package facilitates:

1. **Enhanced Surveillance and Monitoring**  
   PAHOabc enables countries to go beyond basic coverage analysis, facilitating the estimation of innovative indicators such as complete schedule coverage, nominal dropout rates, and other key metrics.

2. **Evidence-Based Decision Making**  
   By providing tools for in-depth data exploration and visualization, PAHOabc supports the use of scientific evidence to guide program decisions and implementation.

3. **Strengthening Data Capabilities**  
   This package aims to strengthen the data analysis capabilities of the human resources that are part of the immunization programs. By empowering countries to leverage their data effectively, PAHOabc contributes to CIM's goal of revitalizing immunization programs and ensuring equitable access to life-saving vaccines.

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
   Evaluates whether individuals have received all required doses in a national immunization schedule. This module differs from standard coverage calculation as it evaluates each individual's compliance of the national immunization schedule.

Each module works seamlessly with the example datasets provided in the package. These examples make it easy to test out the functionality and serve as a reference when preparing your own data. Learn more about these example datasets [in this vignette](https://im-data-paho.github.io/pahoabc/articles/example_datasets_en.html).

> **Note**
> 
> You can explore all the available vignettes by clicking on the **Guides** button in the navigation bar.

## Contribute

We welcome suggestions, bug reports, and feature requests through the [GitHub Issues](https://github.com/IM-Data-PAHO/pahoabc/issues) page. If you'd like to contribute code or fixes, feel free to open a [pull request](https://github.com/IM-Data-PAHO/pahoabc/pulls). 
