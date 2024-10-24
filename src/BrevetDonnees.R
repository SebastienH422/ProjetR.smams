########################################### Dont forget to uncomment #################################
# install.packages("data.table")
# library(data.table)

# 2.3.2. Sources de données (3 data frames)
# ipc_clean_data, epo_app_reg_clean_data, en_ipc_clean_data


# 202202_EPO_App_reg_small.txt

epo_app_reg_all_data = fread(file.path(getwd(), "projetR/Data/202202_EPO_App_reg_small.txt"), 
                      sep = ",", 
                      na.strings = c("", "NA"), 
                      fill = TRUE)
head(epo_app_reg_all_data)

epo_app_reg_clean_data = epo_app_reg_all_data[, c("appln_id", "app_name", "city", "postal_code", "ctry_code")]
epo_app_reg_clean_data # DataTable propre de 202202_EPO_App_reg_small.txt



## 202202_EPO_IPC_small.txt

epo_ipc_all_data = fread(file.path(getwd(), "projetR/Data/202202_EPO_IPC_small.txt"), 
                         sep = ",", 
                         na.strings = c("", "NA"), 
                         fill = TRUE)
head(epo_ipc_all_data)

epo_ipc_clean_data = epo_ipc_all_data[, c("appln_id", "prio_year", "IPC")]
epo_ipc_clean_data # DataTable propre de 202202_EPO_IPC_small.txt


## EN_ipc_section_*_title_list_20120101.txt

all_en_ipc_files = list.files(path = file.path(getwd(), "projetR/Data"),
                           pattern = "EN_ipc_section_.*_title_list_20120101.txt",
                           full.names = TRUE)
all_en_ipc_files

en_ipc_all_data = do.call(rbind,lapply(all_en_ipc_files, function(files) {
  read.table(files,
             sep = "\t",
             header = FALSE,
             fill = TRUE,
             quote = "",
             stringsAsFactors = FALSE)
}))
str(en_ipc_all_data)

en_ipc_all_data <- en_ipc_all_data[!sapply(en_ipc_all_data, is.null)] # enleve les NULLS
colnames(en_ipc_all_data) <- c("IPC_Code", "Description") # name colonnes

# nettoie les descriptions
clean_column_description <- function(df) {
  # Remove text in parentheses, including the parentheses
  desc <- gsub("\\s*\\([^()]*\\)", "", df)
  # Remove text starting with "e.g." or "i.e." and preceding comma or semicolon
  desc <- gsub(",?\\s*e\\.g\\..*?[,;]", "", desc)
  desc <- gsub(",?\\s*i\\.e\\..*?[,;]", "", desc)
  # Remove trailing "e.g." or "i.e." cases
  desc <- gsub(",?\\s*e\\.g\\..*$", "", desc)
  desc <- gsub(",?\\s*i\\.e\\..*$", "", desc)
  # Remove double semicolons
  desc <- gsub(";;", "", desc)
  # Remove any trailing or leading semicolons
  desc <- gsub("^;\\s*|\\s*;$", "", desc)
  # Remove unwanted patterns like "A01B0023040000 takes precedence"
  desc <- gsub("\\s*\\([A-Z0-9]+[\\s\\w]*\\)", "", desc)  # Remove content in parentheses with alphanumeric patterns
  # Replace multiple spaces with a single space
  desc <- gsub("\\s{2,}", " ", desc)
  # Trim leading and trailing whitespace
  desc <- trimws(desc)
  return(desc)
}


en_ipc_clean_data = en_ipc_all_data

en_ipc_clean_data$Description = clean_column_description(en_ipc_clean_data$Description)

head(en_ipc_clean_data)






