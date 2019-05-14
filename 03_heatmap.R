library(heatmaply)
library(tidyverse)
library(d3heatmap)
library(gplots)
#heatmapper not available for R version 3.6

Sys.getlocale()
Sys.setlocale("LC_CTYPE", "german")


df <- read_csv2("./data/Datensatz_Wahl-O-Mat_Europawahl-2019.csv")

Thesen <- read_csv2("./data/Data_pp1-3_haendisch.csv") %>% 
  pull(These) %>% 
  str_remove_all("[0-9]+\\. ") 

Label <- df$Label
df <- df[,-1]
rownames(df) <- Label %>% 
  str_remove_all("[0-9]+\\. ") 

colors <- c("#e21a00", "grey", "chartreuse3")

df.text <- df
df.text[df.text==1] <- 'Ablehnung zu "'
df.text[df.text==2] <- 'Neutral zu "'
df.text[df.text==3] <- 'Zustimmung zu "'


df.text <- df.text %>% 
  map_dfc(~str_c(., Thesen, '"'))

#df.text[] <- lapply( df.text, factor, ordered = TRUE) # the "[]" keeps the dataframe structure
lapply(df.text, class)

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
          file = "./plots/heatmap_alle-Parteien.html",
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

# 2. heatmap for bundestag partys -----------------------------------------------------------

df.EP <- subset(df, select = 1:6)
rownames(df.EP) <- rownames(df)

heatmaply(df.EP,
          file = "./plots/heatmap_BT-Parteien.html",
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


# 3. d3heatmapper ---------------------------------------------------------

d3heatmap(df, 
          colors = colors, 
          revC = TRUE,
          dendrogram = "both", 
          width = 1000,
          height = 600,
          xaxis_height = 100,
          yaxis_width = 250,
          cellnote = df.text,
          k_col = 4)
