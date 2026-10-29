# washb-serology-bangladesh

**Statistical analysis code for the WASH Benefits Bangladesh enteric pathogen serology study**

This repository contains R scripts, Quarto documents, and supporting materials for the analyses, tables, and figures reported in the manuscript below.

## Associated manuscript

**Effects of water quality, sanitation, handwashing and nutritional interventions on enteric pathogen seroconversion in rural Bangladesh: a cluster randomised trial**

**Authors:** Mahbubur Rahman\*, Pearl Anne Ante-Testard\*, Richelle W. Kihoro, Henry Kanyi, Henry Emisiko, Huiyu Hu, Everlyn Kamau, E. Brook Goodhew, Chabier Coleman, Shahjahan Ali, Md Ziaur Rahman, Abul Kasham Shoab, Md. Rana Miah, Sania Ashraf, Sarker M Parvez, Md. Mostofa Shakil, Samantha J. Bents, Julianna Colado, Nikolina Walas, Jessica A. Grembi, Richelle C. Charles, Edward T. Ryan, Claire Munroe, Robert L. Atmar, Jade Benjamin-Chung, Ayse Ercumen, Andrew N. Mertens, Audrie Lin, Patrick J. Lammie, Christine P. Stewart, John M. Colford Jr., Stephen P. Luby, Sammy M. Njenga, Rashidul Haque, Jeffrey W. Priest, Benjamin F. Arnold.

\*Mahbubur Rahman and Pearl Anne Ante-Testard contributed equally to this work.

## Study overview

The study used data from the WASH Benefits Bangladesh cluster-randomised trial to evaluate the effects of water, sanitation, and handwashing (WASH) and nutrition interventions on enteric pathogen serological outcomes among children in rural Bangladesh. The analyses examined pathogen-specific IgG responses to 12 enteric pathogens during the first two years of life.

## Archived materials and data availability

The code, pre-analysis plan, and de-identified study data are archived on Zenodo:

**[https://doi.org/10.5281/zenodo.23671136](https://doi.org/10.5281/zenodo.23671136)**

Use the archived code and corresponding data versions when reproducing the manuscript analyses.

### Geographic data restriction

Study-cluster GPS coordinates are not publicly available. The institutional review board determined that sharing these coordinates could compromise participant privacy.

The spatial-analysis code is included, but outputs requiring the withheld coordinates, including the study map in Figure 1, cannot be reproduced from the public data alone. This restriction applies to analyses requiring geographic location data.

## Software requirements

The analyses were conducted using the following environment:

| Software | Version or details |
| --- | --- |
| R | 4.3.3 |
| Operating system | macOS Sequoia **15.7.7** |
| RStudio IDE | **2026.10.0+233** |

The R packages required for the analyses are identified in `0-config.R`. Quarto is required to render the `.qmd` documents.

## Installation

1. Install [R](https://cran.r-project.org/).
2. Install [RStudio Desktop](https://posit.co/download/rstudio-desktop/) if using the RStudio IDE.
3. Install [Quarto](https://quarto.org/docs/get-started/) if it is not already available in your environment.
4. Review `0-config.R` and install any required R packages that are not already installed.

## Reproducing the analyses

1. Clone the complete repository, or download and extract its source archive:

   ```bash
   git clone https://github.com/proctor-ucsf/washb-serology-bangladesh.git
   cd washb-serology-bangladesh
   ```

2. Obtain the de-identified study data from the Zenodo record linked above.
3. Start a fresh R session with the repository root as the working directory.
4. Place the input files in the locations referenced by the analysis scripts. Check input and output paths in `0-config.R` and the relevant analysis files before execution.
5. Run the R scripts or render the Quarto documents associated with the desired outputs, as listed below. Follow the dependencies defined in each script or document.

Quarto documents can be rendered using the **Render** button in RStudio or the Quarto command-line interface. Configuration and helper scripts needed during rendering must be loaded within the document's execution session.

The tables below map manuscript outputs to their source files; they are not an execution-order list. Output locations are specified in the corresponding scripts.

### Main manuscript

| Output | Source file(s) |
| --- | --- |
| Table 1 | `3-bangl-baseline-table.qmd` |
| Figure 1: study map | `7-bangl-create-map.R` — requires withheld GPS coordinates |
| Figure 2: source values | `2-bangl-consort-table.qmd` |
| Figure 3 | `1-bangl-age-seroprevalence-rct.Qmd` |
| Figure 4 | `4-bangl-primary.qmd` and `0-WASHB-forest-plot-table.R` |
| Figure 5 | `5-bangl-secondary.qmd` and `0-WASHB-forest-plot-table.R` |

### Supplementary materials

| Output | Source file(s) |
| --- | --- |
| Supplementary Figure 1 | `8-bangl-igg-distributions.qmd` |
| Supplementary Table 1 | `3-bangl-baseline-table.qmd` |
| Supplementary Table 2 | `9-bangl-adherence-2x2margin.qmd` |
| Supplementary Table 3 | `4-bangl-primary.qmd` and `0-WASHB-forest-plot-table.R` |
| Supplementary Figure 2 | `4-bangl-primary.qmd` and `0-WASHB-forest-plot-table.R` |
| Supplementary Figure 3 | `1-bangl-age-seroprevalence-rct.Qmd` |
| Supplementary Table 4 | `5-bangl-secondary.qmd` and `0-WASHB-forest-plot-table.R` |
| Supplementary Figure 4 | `5-bangl-secondary.qmd` and `0-WASHB-forest-plot-table.R` |
| Supplementary Figure 5 | `9-bangl-adherence-2x2margin.qmd` |

## Reproducibility notes

- Use the archived code and corresponding input data when comparing results with the manuscript.
- Begin with a fresh R session without restoring a saved workspace.
- The package requirements are specified in `0-config.R`; exact package versions should be recorded with the analysis environment.
- Record session information at the end of each analysis session. For a Quarto analysis, record it within the document's execution session:

  ```r
  sessionInfo()
  ```

- Spatial outputs requiring study-cluster GPS coordinates are subject to the data restriction described above.

## Trial registration

ClinicalTrials.gov: [NCT01590095](https://clinicaltrials.gov/study/NCT01590095)

