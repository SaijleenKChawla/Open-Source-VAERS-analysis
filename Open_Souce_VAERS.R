install.packages(c(
  "tidyverse",
  "janitor",
  "lubridate",
  "here",
  "rmarkdown",
  "knitr",
  "DT",
  "dplyr"
))
library(tidyverse)
library(janitor)
library(lubridate)
library(here)
library(DT)

#Create a data sheet for 2020 AE that only has distinct VAIRS ID and Vaccine type, and new column for 2020
vaers20clean <- X2020VAERSVAX %>%
  select(VAERS_ID, VAX_TYPE) %>%
  mutate(year = 2020) %>%
  relocate(year, .before = VAERS_ID)

#Create a data sheet for 2021 AE that only has distinct VAIRS ID and Vaccine type, and new column for 2020
vaers21clean <- X2021VAERSVAX %>%
  select(VAERS_ID, VAX_TYPE) %>%
  mutate(year = 2021) %>%
  relocate(year, .before = VAERS_ID)

#Create a data sheet for 2022 AE that only has distinct VAIRS ID and Vaccine type, and new column for 2020
vaers22clean <- X2022VAERSVAX %>%
  select(VAERS_ID, VAX_TYPE) %>%
  mutate(year = 2022) %>%
  relocate(year, .before = VAERS_ID)

#Create a data sheet for 2026 AE that only has distinct VAIRS ID and Vaccine type, and new column for 2020
vaers26clean <- X2026VAERSVAX %>%
  select(VAERS_ID, VAX_TYPE) %>%
  mutate(year = 2026) %>%
  relocate(year, .before = VAERS_ID)

vaers20clean$VAERS_ID <- as.character(vaers20clean$VAERS_ID)
vaers21clean$VAERS_ID <- as.character(vaers21clean$VAERS_ID)
vaers22clean$VAERS_ID <- as.character(vaers22clean$VAERS_ID)
vaers26clean$VAERS_ID <- as.character(vaers26clean$VAERS_ID)
  
#Create final combined data sheet 
vax_data <- bind_rows(vaers20clean, vaers21clean, vaers22clean, vaers26clean)

#check for duplicates in vax_data
n_distinct(vax_data$VAERS_ID) #n = 813433 out of 2501622...
# Keep duplicate VAERS_IDs because each row represents a vaccine administered.
# A single VAERS report may involve multiple vaccines.

#what are the different vaccination types that are documented in Vax_data?
#determine potential combination variables 
sort(unique(vax_data$VAX_TYPE))

vax_data %>%
  count(VAX_TYPE, sort = TRUE)

#remove vaccines that are not classified as 
#6 categories: COVID-19, COVID-19-2, FLU, HPV, Shingles, Pneumococcal

vax_data_analysis <- vax_data %>%
  filter(VAX_TYPE %in% c(
    "FLU(H1N1)",
    "FLU3",
    "FLU4",
    "FLUA4",
    "FLUC3",
    "FLUC4",
    "FLUN3",
    "FLUN4",
    "FLUR3",
    "FLUR4",
    "FLUX",
    "FLUX(H1N1)",
    "H5N1",
    "VARCEL",
    "VARZOS",
    "HPV2",
    "HPV4",
    "HPV9",
    "HPVX",
    "COVID19",
    "COVID19-2",
    "PNC",
    "PNC10",
    "PNC13"
  ))


# (1)rename FLU(H1N1)"  "FLU3"       "FLU4"       "FLUA3"      "FLUA4"     
#[25] "FLUC3"      "FLUC4"      "FLUN3"      "FLUN4"      "FLUR3"      "FLUR4"     
#[31] "FLUX"       "FLUX(H1N1)" "H5N1" all as influenza

#(2)Rename "PNC" "PNC10"   "PNC13" as Pneumococcal

#(3)rename "VARCEL"  "VARZOS" as Shingles

#(4)(5)Covid-19, COVID-19-2 leave as is 

#(6)Rename "HPV2""HPV4" "HPV9"  "HPVX" as HPV

vax_data_analysis <- vax_data_analysis %>%
  mutate(
    VAX_GROUP = case_when(
      VAX_TYPE %in% c(
        "FLU(H1N1)",
        "FLU3",
        "FLU4",
        "FLUA4",
        "FLUC3",
        "FLUC4",
        "FLUN3",
        "FLUN4",
        "FLUR3",
        "FLUR4",
        "FLUX",
        "FLUX(H1N1)",
        "H5N1"
      ) ~ "Influenza",
      VAX_TYPE %in% c(
        "PNC", 
        "PNC10",   
        "PNC13"
      ) ~ "Pneumococcal",
      VAX_TYPE %in% c(
        "VARCEL",  
        "VARZOS"
      ) ~ "Shingles",
      VAX_TYPE %in% c(
        "HPV2",
        "HPV4", 
        "HPV9",  
        "HPVX"
      ) ~ "HPV",
      
      TRUE ~ VAX_TYPE
    )
  )


#Recoding Raw Data for analysis: Data should have total: 
#24 rows (6 rows per year(4 years analyzed)), 
#Columns: #of incidents reported, all vaccines administered, year

analysis_table <- vax_data_analysis %>%
  group_by(year, VAX_GROUP) %>%
  summarise(
    adverse_event_reports = n()
  )

#removing this group as adverse events were negligible in data set
analysis_table <- analysis_table %>%
  filter(VAX_GROUP != "COVID19-2")

# Save cleaned yearly datasets
write_csv(vaers20clean, "Clean CSVs/vaers20clean.csv")
write_csv(vaers21clean, "Clean CSVs/vaers21clean.csv")
write_csv(vaers22clean, "Clean CSVs/vaers22clean.csv")
write_csv(vaers26clean, "Clean CSVs/vaers26clean.csv")

# Save combined dataset
write_csv(vax_data, "Clean CSVs/vax_data.csv")

# Save filtered dataset used for analysis
write_csv(vax_data_analysis, "Clean CSVs/vax_data_analysis.csv")

# Save final summarized analysis table
write_csv(analysis_table, "Clean CSVs/analysis_table.csv")

#create a stacked bar graph with 4 columns, that shows the percentage of AE incident 
#for each Vax_type

final_analysis <- VAERS_open_source_AE %>%
  mutate(
    AE_per_million =
      adverse_event_reports /
      `# of vaccines administered (estimates)` * 1000000
  )

write_csv(final_analysis, "Clean CSVs/final_analysis.csv")

ggplot(final_analysis,
       aes(x = factor(year),
           y = AE_per_million,
           fill = VAX_GROUP)) +
  geom_col() +
  labs(
    title = "VAERS Reports per Million Vaccine Doses",
    x = "Year",
    y = "Reports per Million Doses",
    fill = "Vaccine Type"
  ) +
  theme_minimal(base_size = 14)
  


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  