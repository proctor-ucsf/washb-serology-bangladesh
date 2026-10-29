########################################################
#_______________________________________________________
# @Organization --  UCSF 
# @Project -- WASH Benefits Bangladesh 
# @Author -- Samantha Bents, sjbents@stanford.edu, March 17, 2026 
# @Description -- Create map showing EED vs Full Study for Bangladesh 


########################################################
# Load packages 
library(here)
source(here("R","0-config.R"))

########################################################
# Create map of EED vs Full Study
public_ids = read.csv(file = here("data/bangl/public_ids", "public-ids.csv")) %>%
  distinct(dataid, clusterid, block, clusterid_r, block_r)
head(public_ids)

# Block-level gps
gps_dat = read_dta(file = here("data/bangl/gps/untouched", "6. WASHB_Baseline_gps.dta")) %>%
  mutate(dataid = as.numeric(dataid)) %>%
  left_join(public_ids, by = c("dataid")) %>%
  dplyr::select(block, block_r, qgpslong, qgpslat) %>%
  group_by(block) %>%
  mutate(med_qgpslong = median(qgpslong), med_qgpslat = median(qgpslat)) %>%
  ungroup() %>%
  distinct(block, block_r, med_qgpslong, med_qgpslat)
head(gps_dat)

public_clusters = read.csv(file = here("data/bangl/public_ids", "public-ids.csv")) %>%
  distinct(clusterid, block, clusterid_r, block_r)
head(public_clusters)

luminex_bangl <- read.csv(file = here("data/bangl/luminex/final", 
                                      "washb_bangl_luminex_igg_seropos_2025-09-21.csv")) %>%
  left_join(public_clusters, by = c("clusterid")) %>%
  left_join(gps_dat, by = c("block", "block_r")) %>%
  distinct(med_qgpslong, med_qgpslat, eed) %>%
  group_by(med_qgpslong, med_qgpslat) %>%
  arrange(desc(eed == "EED substudy")) %>% 
  slice(1) %>%
  ungroup() %>%
  mutate(Study = eed)

head(luminex_bangl)

admin_b_study <- get_map("district")

study_sites = ggplot(data = luminex_bangl %>%
                       mutate(Study = replace(Study, Study == "Endline sample", "Full study"))) +
  geom_sf(data = admin_b_study, fill = alpha("seagreen", .10),  color = alpha("black", 0.30), lwd = .75) +
  geom_point(aes(x = med_qgpslong, y = med_qgpslat, fill = Study), col = "black", cex = 3, shape = 24) +theme_minimal() +
  ylab("Latitude") + xlab("Longitude") +
  xlim(c(89.9, 90.8)) +
  ylim(c(23.9, 25.0))  +
  theme(legend.position = "bottom") +
  ggtitle(" Randomization blocks") +
  labs(tag = "B") +
  annotation_scale(location = "bl", width_hint = 0.3) + 
  scale_fill_manual(values = c("#1F78B4", "#B2A07A"), name = "") +
  theme(
    plot.title      = element_text(size = 20, face = "bold"), 
    plot.subtitle =   element_text(size = 20), 
    plot.tag         = element_text(face = "bold", size = 20),
    legend.text = element_text(size = 18), legend.title = element_text(size = 20)) + 
  theme(
    axis.title = element_blank(),
    axis.text  = element_blank(),
    axis.ticks = element_blank())
study_sites

########################################################
# Create Bangladesh map
bangladesh_country <- ne_countries(country = "Bangladesh", scale = "medium", returnclass = "sf")
bangladesh_districts <- ne_states(country = "Bangladesh", returnclass = "sf")

# Bounding box from above 
study_box <- st_as_sfc(st_bbox(c(
  xmin = 89.9, xmax = 90.8,
  ymin = 23.9, ymax = 25.0), crs = 4326))

map_inset <- ggplot() +
  geom_sf(data  = study_box,
    fill  = alpha("darkred", 0.15),
    color = "darkred",
    lwd   = 0.8) +
  geom_sf(data = admin_b_study, fill = alpha("seagreen", .10),  color = alpha("black", 0.30), lwd = .25) +
  annotation_scale(location = "bl", width_hint = 0.4) +
  coord_sf(crs = 4326) +
  labs(x = NULL, y = NULL, tag = "A") +
  theme_minimal() +
  theme(axis.text        = element_text(size = 7),
    panel.border     = element_rect(color = "black", fill = NA, linewidth = 0.8),
    plot.tag         = element_text(face = "bold", size = 14),
    panel.background = element_rect(fill = "white", color = NA)) +
  annotate( "text", x = 90.9, y  = 25.90,  
    label = "Randomization\nblocks",
    size  = 5,
    color = "black" )  +
  annotate("segment",
    x    = 90.9, # arrow start  
    xend = 90.6,# arrow end 
    y    = 25.6,  
    yend = 25.1, 
    arrow = arrow(length = unit(0.2, "cm"), type = "closed"),
    color = "darkred",
    lwd   = 0.5)  +
  ggtitle("Bangladesh") +
  theme(plot.title      = element_text(size = 20, face = "bold"), 
    plot.subtitle =   element_text(size = 20), 
    axis.title.x    = element_text(size = 20),   
    axis.title.y    = element_text(size = 20),  
    axis.text.x     = element_text(size = 14),   
    axis.text.y     = element_text(size = 14) ,  
    plot.tag         = element_text(face = "bold", size = 20),
    legend.text = element_text(size = 18), legend.title = element_text(size = 20))
map_inset

########################################################
# Age and time plot for studies 
agetime_bangl <- read.csv(file = here("data/bangl/luminex/final", 
                                      "washb_bangl_luminex_igg_seropos_2025-09-21.csv")) %>%
  left_join(public_id_cluster, by = c("clusterid")) %>%
  distinct(childid, visit, agemonth, sampledate, eed) %>%
  mutate(eed = replace(eed, eed == "Endline sample", "Full study"))
table(agetime_bangl$eed)

age_plot = ggplot(data = agetime_bangl) +
  geom_histogram(aes(x = agemonth, fill = eed), alpha = .7,  position = "identity") +
  ylab("Number of samples") + xlab("Age in months") + theme_minimal() +
  scale_fill_manual(values = c( "#1F78B4", "#B2A07A"), name = "") +
  ggtitle("C") +
  theme(
    plot.title      = element_text(size = 20, face = "bold"),   # title
    plot.subtitle =   element_text(size = 20), 
    axis.title.x    = element_text(size = 20),   # x-axis title
    axis.title.y    = element_text(size = 20),   # y-axis title
    axis.text.x     = element_text(size = 14),   # x-axis tick labels
    axis.text.y     = element_text(size = 14) ,   # y-axis tick labels
    plot.tag         = element_text(face = "bold", size = 20),
    legend.position = "none",
    legend.text = element_text(size = 18), legend.title = element_text(size = 20))
age_plot

time_plot = ggplot(data = agetime_bangl) +
  geom_histogram(aes(x = as.Date(sampledate), fill = eed), alpha = .7, position = "identity") +
  ylab("Number of samples") + xlab("Year") + theme_minimal() +
  scale_fill_manual(values = c( "#1F78B4", "#B2A07A"), name = "") +
  ggtitle("D") +
  theme(
    plot.title      = element_text(size = 20, face = "bold"),   # title
    plot.subtitle =   element_text(size = 20), 
    axis.title.x    = element_text(size = 20),   # x-axis title
    axis.title.y    = element_text(size = 20),   # y-axis title
    axis.text.x     = element_text(size = 14),   # x-axis tick labels
    axis.text.y     = element_text(size = 14) ,   # y-axis tick labels
    plot.tag         = element_text(face = "bold", size = 20),
    legend.position = "bottom",
    legend.text = element_text(size = 18), legend.title = element_text(size = 20))
time_plot

age_time = plot_grid(age_plot, time_plot, nrow = 2, rel_heights = c(.4, .5))

########################################################
# Combine all plots 
plot_grid(map_inset, study_sites, age_time, nrow = 1)
# Dimensions: 1300 x 600



