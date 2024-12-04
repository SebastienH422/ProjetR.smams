library(data.table)
library(stringr)

# Loading and extracting relevant columns
base_emp <- data.table(read.csv(file = "Data/emp_offers_fmt.tsv", head = TRUE, sep = ","))

offres <- base_emp[, .(entreprise, secteur, experience_requise, competences_requises, salaire, departement)]

process_salary <- function(salary_text, entreprise_name) {
  # Check if the salary text is empty or NA
  if (is.na(salary_text) || salary_text == "") {
    return(NA)  # Return NA for empty or missing salaries
  }
  
  # Remove all spaces between numbers
  cleaned_salary_text <- gsub(" ", "", salary_text)
  
  # Convert commas to periods for consistency
  cleaned_salary_text <- gsub(",", ".", cleaned_salary_text)
  
  # If the salary ends with "000", multiply by 1000
  salary_value = 1
  if (grepl("000", cleaned_salary_text) || grepl("K", cleaned_salary_text)) {
    salary_value <- as.numeric(cleaned_salary_text) * 1000
  } else {
    salary_value <- as.numeric(cleaned_salary_text)
  }
  
  # Extract all numbers from the salary string
  numbers <- as.numeric(unlist(str_extract_all(cleaned_salary_text, "\\d+\\.?\\d*")))
  
  # Print the extracted numbers for debugging
  if(entreprise_name == "LHH Recruitment Solutions"){
    print(cleaned_salary_text)
    print(salary_value)
    print(numbers)
  }
  
  # If no numbers are found, return NA
  if (length(numbers) == 0) {
    return(NA)
  }
  
  # Calculate the average of the numbers if there are multiple
  avg_salary <- if (length(numbers) > 1) mean(numbers) else numbers[1]
  
  # Apply multipliers based on keywords only if the text is not NA or empty
  if (!is.na(salary_text) && salary_text != "") {
    if (str_detect(salary_text, "\\bjour\\b")) {
      avg_salary <- avg_salary * 360  # Multiply by 360 for "jour"
    } else if (str_detect(salary_text, "\\bmois\\b")) {
      avg_salary <- avg_salary * 12   # Multiply by 12 for "mois"
    } else if (str_detect(salary_text, "\\bsemaine\\b")) {
      avg_salary <- avg_salary * 52   # Multiply by 52 for "semaine"
    }
  }
  
  if (avg_salary == floor(avg_salary)) {
    formatted_salary <- format(avg_salary, nsmall = 0)  # No decimal places
  } else {
    formatted_salary <- format(round(avg_salary, 2), nsmall = 2)  # Two decimal places
  }
  
  return(formatted_salary)
}




# Apply the salary processing function
offres[, avg_wage := mapply(process_salary, salaire, entreprise)]

# Conversion of experience_requise to numeric (if necessary)
offres[, experience_requise := as.numeric(experience_requise)]

# Function to clean up and process the competences list
clean_competences <- function(skills_text) {
  # Remove leading and trailing commas and whitespace
  cleaned_text <- str_trim(gsub("^,|,$", "", skills_text))
  return(cleaned_text)
}

# Function to find the top 4 most frequent skills
get_top_skills <- function(skills_list) {
  # Clean the competences list and flatten into a single vector
  cleaned_skills <- unlist(str_split(clean_competences(skills_list), ",\\s*"))
  cleaned_skills <- cleaned_skills[cleaned_skills != ""]
  
  # If there are no skills, return NA as a character
  if (length(cleaned_skills) == 0) {
    return(NA_character_)
  }
  
  # Count occurrences of each skill
  skill_counts <- sort(table(cleaned_skills), decreasing = TRUE)
  
  # Get the top skills, limiting to 4 or fewer
  top_skills <- names(skill_counts)[1:min(4, length(skill_counts))]
  
  # Concatenate the top skills into a single string
  return(paste(top_skills, collapse = ", "))
}

# Function to find the most frequent sector
get_top_sectors <- function(sector_list) {
  # Remove any empty or NA values
  valid_sectors <- sector_list[!is.na(sector_list) & sector_list != ""]
  
  # If no valid sectors are found, return NA as a character
  if (length(valid_sectors) == 0) {
    return(NA_character_)
  }
  
  # Count occurrences of each sector
  sector_counts <- sort(table(valid_sectors), decreasing = TRUE)
  
  # Get the top 4 most frequent sectors (or fewer if there aren't 4)
  top_sectors <- names(sector_counts)[1:min(4, length(sector_counts))]
  
  # Concatenate the top sectors into a single string, separated by commas
  return(paste(top_sectors, collapse = ", "))
}

# Clean competences_requises column before grouping
offres[, competences_requises := sapply(competences_requises, clean_competences)]

# Group by firm_name and compute the metrics
offres_grouped <- offres[, .(
  firm_name = unique(entreprise),                          # Firm name
  n_offres = .N,                                           # Number of offers
  sector_main = get_top_sectors(secteur),                   # Top 4 most common sectors
  avg_req_exp = sum(experience_requise, na.rm = TRUE) / sum(!is.na(experience_requise)), # Average experience
  avg_wage = 0,                  # Average annual salary
  # avg_wage = mean(avg_wage, na.rm = TRUE),                  # Average annual salary
  addr_dept_main = names(sort(table(departement), decreasing = TRUE))[1],  # Most common department
  top_skill_req = get_top_skills(competences_requises)      # Top 4 most frequent skills
), by = entreprise]

# Remove the "entreprise" column and rename grouped by "firm_name"
offres_grouped[, entreprise := NULL]

# Print the final grouped results
# View(offres_grouped)

