# Tesseract ---------------------------------------------------------------
library(tabulizer)
library(magick)
library(tesseract)
library(tidyverse)

#set working directory temporarily to subfolder "pdf-scraping"
wd <- getwd()
setwd("./pdf-scraping/")

#url <- "https://www.wahl-o-mat.de/europawahl2019/Positionsvergleich-Europawahl2019.pdf"
#download.file(url, "positions.pdf", mode = "wb")
tesseract_download("eng", getwd()) 

"positions.pdf" %>% 
  image_read_pdf(pages = 1:10, density = 600) %>% 
  image_crop(geometry = "1140x5880+3540+630") %>% 
  image_append(stack = F) %>% 
  image_write("positions.png", format = "png")

positions <- "positions.png" %>% 
  ocr_data(engine = tesseract(language = "eng",
                              datapath = getwd(),
                              options = list(tessedit_char_whitelist = "X_V"),
                              cache = F))

key = tibble(x = c("xX", "Y", "-", "VY", "x", "â\200”", "Xx", "v", "â\200”-", "Vv"),
             y = c("Ablehnung", "Zustimmung", "Neutral", "Zustimmung", "Ablehnung", 
                   "Neutral", "Ablehnung", "Zustimmung", "Neutral", "Zustimmung"))

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

positions <- positions %>% 
  left_join(key, by = c("word" = "x")) %>% 
  pull(y) %>% 
  matrix(nrow = 38, ncol = 40, byrow = T) %>% 
  as_tibble %>% 
  set_names(parteien)

# Thesen ------------------------------------------------------------------
extract_text("positions.pdf", pages = 1, encoding = "UTF-8") %>% 
  str_split("\\r\\n[0-9]+\\. ") %>% 
  unlist %>% 
  str_replace_all("(1.|\\r\\nWahl-O-Mat® Europawahl 2019\\r\\nVergleich der Positionen\\r\\n1/12\\r\\n|\\r\\n)", " ") %>% 
  str_squish

positions <- positions %>% 
  mutate(thesen = extract_text("positions.pdf", pages = 1, encoding = "UTF-8") %>% 
           str_split("\\r\\n[0-9]+\\. ") %>% 
           unlist %>% 
           str_replace_all("(1.|
                           \\r\\nWahl-O-Mat® Europawahl 2019\\r\\nVergleich der Positionen\\r\\n1/12\\r\\n|
                           \\r\\n)", 
                           " ") %>% 
           str_squish)

write_rds(positions, "positions.rds")

#reset working directory
setwd(wd)
