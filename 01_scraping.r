library(tidyverse)
library(tabulizer)

# https://www.wahl-o-mat.de/europawahl2019/Positionsvergleich-Europawahl2019.pdf

# Tesseract ---------------------------------------------------------------
library(magick)
library(tesseract)
# tesseract_download("deu", getwd()) 

files <- str_c("Positionsvergleich-Europawahl2019_", 1:10, ".png")

files %>% 
  map(image_read) %>% 
  map(image_crop, geometry = "1140x5880+3540+630") %>% 
  map2(str_c("cut/", files), image_write, format = "png")

wahl <- str_c("cut/", files) %>% 
  map(ocr_data, engine = tesseract(language = "deu", 
                                   datapath = getwd(),
                                   options = list(tessedit_char_whitelist = "X_V"),
                                   cache = F))

wahl1 <- wahl %>% 
  map(~.[["word"]]) %>% 
  .[-(9:10)] %>% 
  map(~matrix(., ncol = 4, byrow = T)) %>% 
  map(as_tibble) %>% 
  bind_cols()

write_rds(wahl1, "data_pp.1-8.rds")

wahl_ta <- ocr_data("samu_stinkt.png", 
                    tesseract(language = "deu", 
                              datapath = getwd(),
                              options = list(tessedit_char_whitelist = "X_V")))



matrix(wahl[[1]][["word"]], ncol = 4, byrow = T) %>% View
