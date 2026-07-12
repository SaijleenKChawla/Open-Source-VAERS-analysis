# Open-Source-VAERS-analysis
is the increase in adverse event documentation due to the mass population spike in vaccination in 2021 and 2022 statistically significant and correlated to higher rates of adverse reactions due to the COVID-19 and COVID-19-2 vaccinations? 


Workflow: 
# Open-Source VAERS Analysis

## Overview

This project investigates trends in reported adverse events submitted to the Vaccine Adverse Event Reporting System (VAERS) before, during, and after the COVID-19 vaccination campaign.

The goal is to determine whether changes in reporting frequency during 2021–2022 remain after accounting for vaccination uptake and to explore temporal trends in reported adverse events.

---

## Research Question

How did reported adverse events in VAERS change during the COVID-19 vaccination campaign (2021–2022) compared with surrounding years after standardizing for vaccine administration population administration spike?

---

## Data



---

## Planned Workflow
VAERSDATA
          \
VAERSSYMPTOMS ----> Merge ----> Clean ---->
          /
VAERSVAX

                    +
          CDC vaccination data

                    ↓

      reports per million doses

                    ↓

      plots + statistical tests
      
1. Import and clean datasets.
2. Merge VAERS tables.
3. Filter years of interest.
4. Summarize reports by vaccine type.
5. Standardize reports by vaccine doses administered.
6. Create exploratory visualizations.
7. Perform statistical analyses.
8. Document findings in R Markdown.

---

## Current Status
