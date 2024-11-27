library(data.table)
library(stringr)

# Loading and extracting relevant columns
base_emp = data.table(read.csv(file = "Data/emp_offers_fmt.tsv",
                               head = TRUE,
                               sep = ","))

offres = base_emp[, .(entreprise, secteur, experience_requise, competences_requises, salaire, departement)]

# Function to extract and process salary
process_salary <- function(salary_text) {
  # Extract all numbers from the salary string
  numbers <- as.numeric(unlist(str_extract_all(salary_text, "\\d+")))
  
  if (length(numbers) == 0) {
    return(NA)  # If no numbers found, return NA
  }
  
  # Calculate the average of the numbers
  avg_salary <- mean(numbers, na.rm = TRUE)
  
  # Determine the multiplier based on keywords in the text
  if (str_detect(salary_text, "\\bjour\\b")) {
    avg_salary <- avg_salary * 360  # Multiply by 360 if "jour" is found
  } else if (str_detect(salary_text, "\\bmois\\b")) {
    avg_salary <- avg_salary * 12   # Multiply by 12 if "mois" is found
  }
  
  return(avg_salary)
}

# Apply the salary processing function
offres[, avg_wage := sapply(salaire, process_salary)]

# Conversion of experience_requise to numeric (if necessary)
offres[, experience_requise := as.numeric(experience_requise)]

# Group by firm_name (equivalent to "entreprise")
offres_grouped = offres[, .(
  firm_name = unique(entreprise),                          # Firm name (unique for each group)
  n_offres = .N,                                           # Number of offers
  sector_main = names(sort(table(secteur), decreasing = TRUE))[1],  # Most common sector
  avg_req_exp = sum(experience_requise, na.rm = TRUE) / sum(!is.na(experience_requise)), # Average experience (ignoring NaN)
  avg_wage = mean(avg_wage, na.rm = TRUE),                 # Average annual salary
  addr_dept_main = names(sort(table(departement), decreasing = TRUE))[1]  # Most common department
), by = entreprise]

# Remove the "entreprise" column and rename grouped by "firm_name"
offres_grouped[, entreprise := NULL]

# View the updated grouped data
View(offres_grouped)
