############
#
# This script was used in an older version and is now replaced by script "01_scraping.r"
#
############




library(stringr)
data.raw <- readRDS("data_pp.1-8.rds")

data.raw <- data.raw %>% map(str_to_lower) %>% as_tibble

pos <- data.raw %>% map(str_detect, "v") %>% as_tibble %>% as.matrix
neg <- data.raw %>% map(str_detect, "x") %>% as_tibble %>% as.matrix
neut <- data.raw %>% map(str_detect, 'â€”|_|=') %>% as_tibble %>% as.matrix

data.clean <- data.raw
data.clean[pos] <- 3
data.clean[neg] <- 1
data.clean[neut] <- 2

data9.10 <- read_csv2("Data_pp9-10.csv", col_names = FALSE)
data.clean <- cbind(data.clean, data9.10)

parteien <- c("CDU/CSU", "SPD", "Grüne", "DIE LINKE", 
              "AfD", "FDP", "FREIE WÄHLER", "Piratenpartei", 
              "Tierschutzpartei", "NPD", "Familienpartei","ÖDP", 
              "Die PARTEI", "Volksabstimmung", "Bayernpartei", "DKP", 
              "MLPD", "SGP", "TIERSCHUTZ", "Tierschutzallianz", 
              "Bündnis C", "BIG", "BGE", "DIE DIREKTEI",
              "DiEM25", "III.Weg", "Die Grauen", "DIE RECHTE", 
              "DIE VIOLETTEN", "LIEBE", "DIE FRAUEN", "Graue Panther", 
              "LKR", "MENSCHLICHE WELT", "NL", "ÖkoLinX", 
              "Die Humanisten", "Partei für die Tiere", "Gesundheitsforschung", "Volt")

names(data.clean) <- parteien



# Data Validation ---------------------------------------------------------

data.validation <- read_csv2("Data_pp1-3_haendisch.csv") 
data.validation[,3:14]==data.clean[1:12]

data.clean$Label <- paste(1:38, ". ", data.validation$Label, sep = "")

write_csv2(data.clean[, c(41,1:40)], path = "Datensatz_Wahl-O-Mat_Europawahl-2019.csv")
