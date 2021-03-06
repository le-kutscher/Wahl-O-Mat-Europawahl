library(heatmaply)
library(tidyverse)
library(d3heatmap)
library(gplots)
library(htmlwidgets)
library(jsonlite)
library(reshape2)
library(r2d3)

Sys.getlocale()
Sys.setlocale("LC_CTYPE", "german")


# 1. Data Preparation -----------------------------------------------------

df <- read_csv2("./data/Datensatz_Wahl-O-Mat_Europawahl-2019.csv")

Thesen <- read_csv2("./data/Data_pp1-3_haendisch.csv") %>% 
  pull(These) %>% 
  str_remove_all("[0-9]+\\. ") 

Label <- df$Label
df <- df[,-1]
rownames(df) <- Label %>% 
  str_remove_all("[0-9]+\\. ") 

colors <- c("#e21a00", "grey", "chartreuse3")

#create a dataframe with the texts for the hover
df.text <- df
df.text[df.text==1] <- 'Ablehnung zu "'
df.text[df.text==2] <- 'Neutral zu "'
df.text[df.text==3] <- 'Zustimmung zu "'

df.text <- df.text %>% 
  map_dfc(~str_c(., Thesen, '"'))

#agreement_level <- c("Ablehnung zu '", "Neutral zu '", "Zustimmung zu '")
#df$question <- rownames(df)
#melt(df, id = "question") %>% 
#  mutate(label = paste0(agreement_level[value], Thesen, "'")) %>% 
#  write_csv("./data/wahl-o-mat-all.csv")
#melt(df[,c(1:6, 41)], id = "question") %>% 
#  mutate(label = paste0(agreement_level[value], Thesen, "'")) %>% 
#  write_csv("./data/wahl-o-mat-bt.csv")


# 2. d3heatmapper ---------------------------------------------------------
#temporarily change working directory to subfolder plots
wd <- getwd()
setwd("./plots/")

d3 <- d3heatmap(df, 
          colors = colors, 
          revC = TRUE,
          dendrogram = "both", 
          width = 1000,
          height = 600,
          xaxis_height = 100,
          yaxis_width = 250,
          cellnote = df.text,
          k_col = 4)
save_d3_html(d3, file = "d3heatmap-alle-Parteien.html")

#Bundestagsparteien
df.BT <- subset(df, select = 1:6)
df.text.BT <- subset(df.text, select = 1:6)
rownames(df.BT) <- rownames(df)

d3.BT <- d3heatmap(df.BT, 
                colors = colors, 
                revC = TRUE,
                dendrogram = "both", 
                width = 1000,
                height = 600,
                xaxis_height = 100,
                yaxis_width = 250,
                cellnote = df.text.BT,
                k_col = 2)
save_d3_html(d3.BT, file = "d3heatmap-BT-Parteien.html")

#count similarities between parties
similarity <- function(df){ #create function for creating matrix that shows how many common positions every party has with one another
  diff <- matrix(nrow = ncol(df), ncol = ncol(df)) %>% as_tibble()
  names(diff) <- names(df)
  diff$party <- names(df)
  for(party in 1:ncol(df)){
    for (i in 1:ncol(df)) {
      diff[party,i] <- sum(df[,party] == df[,i])
    }
  }
  print(diff[,c(ncol(df)+1, 1:ncol(df))])
} 
similarity.df <- similarity(df)
similarity.df.BT <- similarity(df.BT)

#reset working directory
setwd(wd)

# heatmaply ---------------------------------------------------------------
# this is only to try out an alternative package, not used finally

#v1: simple
heatmaply(df,
          colors = colors, 
          grid_gap = 1,
          hide_colorbar = TRUE,
          #custom_hovertext = df.text, 
          #showticklabels = FALSE,
          #plot_method = "ggplot", 
          label_names = c("<b>These: </b>", "Partei: ", "Position: "))

#v2
#cc <- rep("blue", 40)
heatmaply(df,
          #file = "./plots/heatmap_alle-Parteien.html",
          colors = colors, 
          fontsize_col = 8,
          #cexRow = 0.8,
          fontsize_row = 8,
          width = 800,
          height = 500,
          grid_gap = 1,
          hide_colorbar = TRUE,
          #seriate = "GW",         #another type of matrix arranging
          custom_hovertext = df.text, 
          #dendrogram = "column", 
          #showticklabels = FALSE,  
          plot_method = "ggplot", 
          revC = TRUE,
          #labRow = rownames(df),
          labCol = names(df),
          label_names = c("<b>These</b> (N° und Abkürzung)", "<b>Partei</b> ", "<b>Position</b>"))


df.EP <- subset(df, select = 1:6)
rownames(df.EP) <- rownames(df)

heatmaply(df.EP,
          #file = "./plots/heatmap_BT-Parteien.html",
          colors = colors, 
          fontsize_col = 8,
          #cexRow = 0.8,
          fontsize_row = 8,
          width = 800,
          height = 500,
          grid_gap = 1,
          hide_colorbar = TRUE,
          #seriate = "GW",         #another type of matrix arranging
          custom_hovertext = df.text, 
          #dendrogram = "none", 
          #showticklabels = FALSE,  
          plot_method = "ggplot", 
          revC = FALSE,
          labRow = df.EP$Label,
          labCol = names(df.EP),
          label_names = c("<b>These</b> (N° und Abkürzung)", "<b>Partei</b> ", "<b>Position</b>"))



