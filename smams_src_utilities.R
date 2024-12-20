#
# Simon Fraile, Matilin Periat, Ahina Durrieu, Maina Boivent, Sébastien Hein
# 
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Employment section
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# 
# Auxiliary functions

# Function to clean up and process the competences list
clean_competences = function(skills_text) {
  # Remove leading and trailing commas and whitespace
  cleaned_text = str_trim(gsub("^,|,$", "", skills_text))
  return(cleaned_text)
}

# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Functions to build base_emp columns
# _____________________________________________________________________________________________________________________________
# --> Used for top_skill_req         
get_skills_req = function(line){ 
  # IN: skills <string> number of skills in various formats found in competences_requises
  # OUT: <list of string> required skills, one skill per string
  if (!is.null(line['competences_requises'])) {
    skills = line['competences_requises']
  } else {
    skills = NaN
  }
  return(str_split(string = stringi::stri_trans_general(tolower(skills), "Latin-ASCII"),
                   pattern = ', '))
}
# _____________________________________________________________________________________________________________________________
# --> Used for sector_name       
get_sector_name = function(line){ 
  # IN: sector <string> number of sectors in various formats found in competences_requises
  # OUT: <list of string> required sectors, one sector per string
  if (!is.null(line['secteur'])) {
    sector = line['secteur']
  } else {
    sector = NaN
  }
  return(str_split(string = stringi::stri_trans_general(tolower(sector), "Latin-ASCII"),
                   pattern = ', '))
}

# _____________________________________________________________________________________________________________________________
# Used for avg_wage

get_wage = function(wage) {
  # IN: wage <string> Salary or salary range in various formats found in the salaire column
  # OUT: <float> Salary or average salary if it's a range

  if (is.na(wage) || wage == "") {
    return(NA_real_)
  }
  
  # Clean the salary text
  wage <- gsub(" ", "", wage)        # Remove spaces
  wage <- gsub(",", ".", wage)       # Convert commas to dots

  # Detect multipliers and normalize
  multiplier <- 1
  if (grepl("K", wage, ignore.case = TRUE)) {
    multiplier <- 1000
    wage <- gsub("[Kk]", "", wage)
  } else if (grepl("000", wage)) {
    wage <- gsub("000", "", wage)
    multiplier <- 1000
  }
  
  # Extract numbers
  numbers <- as.numeric(unlist(str_extract_all(wage, "\\d+\\.?\\d*")))

  if (length(numbers) == 0 || any(is.na(numbers))) {
    return(NA_real_)
  }
  
  # Calculate the average if it's a range
  avg_wage <- mean(numbers) * multiplier
  
  # Adjust for periods (day, month, week)
  if (str_detect(wage, "jour")) {
    avg_wage <- avg_wage * 365
  } else if (str_detect(wage, "mois")) {
    avg_wage <- avg_wage * 12
  } else if (str_detect(wage, "semaine")) {
    avg_wage <- avg_wage * 52
  }
  

  # Return with 2 decimals
  return(round(avg_wage, 2))
}


# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Functions to apply after aggregation 
# _____________________________________________________________________________________________________________________________
#
set_firm_name = function(names) {
  # IN: names <list of string> Company names
  # OUT: <string> The first name, or the most frequent one
  
  # If there are no names, return NA
  if (length(names) == 0) {
    return(NA)
  }
  
  # Count occurrences of each name
  names_counts = sort(table(names), decreasing = TRUE)
  
  # Get the top name
  top_names = names(names_counts)[1]
  
  # Concatenate the top name
  return(top_names)
}

# _____________________________________________________________________________________________________________________________
#
get_top_val = function(val_list, n) {
  # IN: val_lists <list> List of values
  #     n <int> number of desired sectors
  # OUT: List of the n most frequent values
  
  # Ensure val_list is treated as a character vector
  val_list = as.character(val_list)
  
  # Split the string values by comma and remove extra spaces
  valid_val = unlist(strsplit(val_list, ",\\s*"))
  
  # Remove any empty or NA values
  valid_val = valid_val[!is.na(valid_val) & valid_val != ""]
  
  # If no valid val are found, return NA
  if (length(valid_val) == 0) {
    return(NA_character_)
  }
  
  # Count occurrences of each val
  val_counts = sort(table(valid_val), decreasing = TRUE)
  
  # Get the top n most frequent val (or fewer if there aren't n)
  top_val = names(val_counts)[1:min(n, length(val_counts))]
  
  # Concatenate the top val into a single string, separated by commas
  return(paste(top_val, collapse = ", "))
}

get_most_frequent = function(val_list) {
  # IN: val_lists <list> List of values (skills)
  # OUT: List of the most frequent values (>1 occurrence),
  #      or all values if they appear only once
  
  # Ensure val_list is treated as a character vector
  val_list = as.character(val_list)
  
  # Split the string values by comma and remove extra spaces
  valid_val = unlist(strsplit(val_list, ",\\s*"))
  
  # Remove any empty or NA values
  valid_val = valid_val[!is.na(valid_val) & valid_val != ""]
  
  # If no valid val are found, return NA
  if (length(valid_val) == 0) {
    return(NA_character_)
  }
  
  # To avoid doubles, replace some words or characters
  valid_val = str_replace_all(valid_val, c("ô" = "o", "English" = "Anglais", "Autonomous" = "Autonome", "French" = "Français"))
  valid_val = str_replace_all(valid_val, c("Communication Skills" = "Communication", "Curious" = "Curiosité", "Artificial intelligence" = "Intelligence artificielle"))
  valid_val = str_replace_all(valid_val, c("Base de donnée" = "Database", "Bases de donnée" = "Database"))
  
  # Count occurrences of each value
  val_counts = table(valid_val)
  
  # Filter to keep only values that appear more than once
  frequent_vals = names(val_counts[val_counts > 1])
  
  if (length(frequent_vals) > 0) {
    # Sort frequent values by occurrence
    frequent_counts = sort(val_counts[frequent_vals], decreasing = TRUE)
    top_values = names(frequent_counts)
  } else {
    # If all values appear only once, return all values
    top_values = names(sort(val_counts, decreasing = TRUE))
  }

  # Limit top_values to two values maximum
  top_values = top_values[1:min(2, length(top_values))]
  
  # Concatenate the top values into a single string, separated by commas
  return(paste(top_values, collapse = ", "))
}

# _____________________________________________________________________________________________________________________________
#
get_id_firm = function(line) {
  if (!is.null(line['entreprise'])) {
    name = line['entreprise'] # Company name
    
    # The following words often appear as the first word in the company name, they are not sufficient to identify the company, we ignore them to build the id_firm_name identifier
    to_ignore = c('groupe', 'la', 'caisse', 'le', 'groupement', 'air', 'the', 'centre', 'direction', 'departement')
    name = tolower(name)

    name = stringi::stri_trans_general(tolower(name), "Latin-ASCII")


    name = gsub(',','',name)
    k = 0
    while (word(name, k, k) %in% to_ignore){
      k = k + 1
    }

    return (word(name, k, k)) # First 4 characters
  } else {
    stop("The 'entreprise' column is missing in the 'line' object")
  }
}

# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Patent section
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
#
find_top_ipc <- function(ipc_codes) {
  ipc_counts <- sort(table(ipc_codes), decreasing = TRUE)
  top_ipc <- names(ipc_counts)[1:2]
  return(top_ipc)
} 

# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
# Match section
# _____________________________________________________________________________________________________________________________
# _____________________________________________________________________________________________________________________________
#

# _____________________________________________________________________________________________________________________________
# Helper function to choose a non-NA value, or randomly if multiple non-NA values
#
choose_non_na = function(x) {
  # Ensure x is a vector of the same type
  x <- as.vector(x)
  x_unique <- unique(x[!is.na(x)])
  if(length(x_unique) == 0) return(x[1])  # Return NA of the correct type
  if(length(x_unique) == 1) return(x_unique[1])
  return(sample(x_unique, 1))
}
