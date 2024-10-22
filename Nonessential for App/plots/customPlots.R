library(tidyverse)
library(calecopal)
library(wesanderson)
library(ggdark)
env <- read_csv("AquaticOrganisms_Clean_Final.csv", guess_max = 10000)
human <- read_csv("Humans_Clean_Final.csv", guess_max = 10000)

#add column to specify where dataset came from
envLabel <- c("Env")
env<- cbind(data.frame(DataType = envLabel), env)
humanLabel <- c("Human")
human <- cbind(data.frame(DataType = humanLabel), human)

#select just what we need
env_sum <- env %>% 
  select(DataType, doi, year, invitro.invivo)
human_sum <- human %>% 
  select(DataType, doi, year, invitro.invivo)

#make new df with all
allData <- rbind(human_sum, env_sum)

#summary table by year
allData_summary_year <- allData %>% 
  group_by(year, DataType) %>% 
  summarize(measurements = n(), studies = n_distinct(doi))
allData_summary_year

#summary table by invitroinvivo
allData_summary_vitro <- allData %>% 
  group_by(invitro.invivo, DataType) %>% 
  summarize(measurements = n(), studies = n_distinct(doi))
allData_summary_vitro

#build custom theme
overviewTheme <- function(){
  dark_theme_classic() %+replace%
    theme(text = element_text(size=17), plot.title = element_text(hjust = 0.5, face="bold",size=20),legend.position = "right",
          axis.text.x = element_text()) }
#p.lot
 year_study.plot <- ggplot(allData_summary_year,aes(fill = DataType, y = studies, x = as.numeric(year))) +
  geom_bar(position="stack", stat="identity") +
   scale_x_continuous(breaks = seq(from = 1993, to = 2021, by = 1 ))+ #show all dates
  #geom_text(aes(label= paste0(studies)), position = position_stack(vjust = 0.5),colour="black") +
  scale_fill_manual(values = cal_palette("superbloom2"), labels = c("Environment", "Human"))+
  ylab("Number of Studies") +
  labs(fill="Organism Model") +
  ggtitle("Microplastics Toxicity Studies over Time")+
  guides(x = guide_axis(angle = 45))+
  dark_theme_minimal() +
   theme(text = element_text(size = 17),
         legend.position = c(0.25, 0.85),
         plot.title = element_text(hjust = 0.5, face="bold",size=20),
         legend.title = element_blank(),
         legend.text = element_text(size = 30),
         panel.grid.major = element_blank(), 
         panel.grid.minor = element_blank(),
         axis.text = element_text(size = 16),
         panel.background = element_rect(color = NULL))
year_study.plot #print

#save
ggsave(year_study.plot,
       filename = "plots/ToxStudiesByTypeAndYear.jpeg",
       width = 6,
       height = 3,
       units = "in",
       device = "jpeg",
       dpi =320,
       scale = 2)

#plot measurements by study type
year_measurement.plot <- ggplot(allData_summary_year,aes(fill = DataType, y = measurements, x = as.numeric(year))) +
  geom_bar(position="stack", stat="identity") +
  scale_x_continuous(breaks = seq(from = 1993, to = 2021, by = 1 ))+ #show all dates
  #geom_text(aes(label= paste0(studies)), position = position_stack(vjust = 0.5),colour="black") +
  scale_fill_manual(values = cal_palette("superbloom2"), labels = c("Environment", "Human"))+
  ylab("Number of Measurements in Database") +
  labs(fill="Organism Model") +
  ggtitle("Microplastics Toxicity Measurements over Time")+
  guides(x = guide_axis(angle = 45))+
  dark_theme_minimal() +
  theme(text = element_text(size = 17),
        legend.position = c(0.25, 0.85),
        plot.title = element_text(hjust = 0.5, face="bold",size=20),
        legend.title = element_blank(),
        legend.text = element_text(size = 30),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text = element_text(size = 16))
year_measurement.plot #print

#plot by in vitro/in vivo
vitro_measurement.plot <- ggplot(allData_summary_vitro,aes(fill = invitro.invivo, y = measurements, x = DataType)) +
  geom_bar(position="stack", stat="identity") +
  #geom_text(aes(label= paste0(studies)), position = position_stack(vjust = 0.5),colour="black") +
  scale_fill_manual(values = wes_palette("Darjeeling1"), labels = c("in vitro", "in vivo"))+
  scale_x_discrete(labels = c("Ecological", "Mammalian")) +
  ylab("Number of Endpoints Measured") +
  labs(fill="In vitro or In vivo") +
  ggtitle("Microplastics Toxicity Studies by Type")+
 # guides(x = guide_axis(angle = 45))+
  dark_theme_minimal() +
  theme(text = element_text(size = 17, color = "white"),
        axis.ticks.y = element_line(),
        plot.title = element_text(hjust = 0.5, face="bold",size=20),
        legend.title = element_blank(),
        legend.text = element_text(size = 20, face = "italic"),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text = element_text(size = 18, color = "white"),
        axis.title = element_blank())
vitro_measurement.plot #print

#save
ggsave(vitro_measurement.plot,
       filename = "plots/vitro_measurementPlot.png",
       width = 6,
       height = 3,
       units = "in",
       device = "png",
       dpi =320,
       scale = 2)

####plot by in vitro/in vivo (humans only)

#summary table by invitroinvivo and year (humans only)
human_summary_vitro <- allData %>% 
  filter(DataType == "Human") %>% 
  group_by(year, invitro.invivo) %>% 
  summarize(measurements = n(), studies = n_distinct(doi))
human_summary_vitro
  


year_study.plot.human <- ggplot(human_summary_vitro,aes(fill = invitro.invivo, y = studies, x = as.numeric(year))) +
  geom_bar(position="stack", stat="identity") +
  geom_text(aes(label= paste0(studies)), position = position_stack(vjust = 0.5),colour="black") +
  scale_x_continuous(breaks = seq(from = 1993, to = 2021, by = 1 ))+ #show all dates
  #geom_text(aes(label= paste0(studies)), position = position_stack(vjust = 0.5),colour="black") +
  scale_fill_manual(values = cal_palette("superbloom2"), labels = c("in vitro", "in vivo"))+
  ylab("Number of Studies") +
  xlab("Year") +
  labs(fill="Organism Model") +
  ggtitle("Microplastics Mammalian Toxicity Studies over Time")+
  guides(x = guide_axis(angle = 45))+
  dark_theme_minimal() +
  theme(text = element_text(size = 17),
        legend.position = c(0.25, 0.85),
        plot.title = element_text(hjust = 0.5, face="bold",size=20),
        legend.title = element_blank(),
        legend.text = element_text(size = 30),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        axis.text = element_text(size = 16),
        panel.background = element_rect(color = NULL))
year_study.plot.human #print

#save
ggsave(year_study.plot.human,
       filename = "plots/year_study.plot.human.jpeg",
       width = 6,
       height = 3,
       units = "in",
       device = "jpeg",
       dpi =320,
       scale = 2)
 