# Table + forest panels for WASH Benefits serology.
# Simple fixed workflow:
# 1) Read both 24m and 12m data
# 2) Build 4 panels (WASH/Nutrition x 24m/12m)
# 3) Save two patchworks (one for 24m, one for 12m)

library(here)
source(here("R","0-config.R"))

# Output folder
out_fig_dir <- file.path("output", "manuscript-figures")
dir.create(out_fig_dir, recursive = TRUE, showWarnings = FALSE)

# Input data
manuscript_24m_file <- file.path("output", "washbb-forest-plot-table-24m.csv")
manuscript_12m_file <- file.path("output", "washbb-forest-plot-table-12m.csv")

manuscript_24m <- read_csv(manuscript_24m_file, show_col_types = FALSE) %>%
  filter(pathogen != "S. stercoralis (NIE)") # removed S. stercoralis (NIE) due to very low events
manuscript_12m <- read_csv(manuscript_12m_file, show_col_types = FALSE) %>%
  filter(pathogen != "S. stercoralis (NIE)") # removed S. stercoralis (NIE) due to very low events

# Formatting helpers
format_p_label <- function(x) {
  p <- suppressWarnings(as.numeric(x))
  ifelse(is.na(p), "",
         ifelse(p < 0.005, "<0.01", formatC(p, format = "f", digits = 2)))
}

build_manuscript_panel_df <- function(manuscript_df, intervention_name, group_labels) {
  panel_df <- manuscript_df %>%
    filter(intervention == intervention_name) %>%
    transmute(
      pathogen = as.character(pathogen_display),
      group0 = group0_label,
      group1 = group1_label,
      diff_label = diff_label,
      p_label = format_p_label(primary_p),
      fdr_label = format_p_label(primary_p_fdr),
      estimate = estimate_pp,
      lcl = min95_pp,
      ucl = max95_pp
    )

  attr(panel_df, "group_labels") <- group_labels
  panel_df
}

# Figure generator (table + forest)
make_margin_panel <- function(df, panel_tag, 
                              forest_color) {
  group_labels <- attr(df, "group_labels")

  n_rows <- nrow(df)
  row_step <- 0.6
  header_gap <- 0.48
  y_bottom_pad <- 0.22
  y_top_pad <- 0.40
  table_text_size <- 3.65
  header_text_size <- 3.60

  df <- df %>% mutate(y = rev(seq(1, by = row_step, length.out = n_rows)))
  x_pos <- c(0.0, 2.50, 3.40, 4.35, 5.25, 6.10)
  headers <- c("Pathogen", group_labels[2], group_labels[1], "Diff (95% CI)", "p-value", "FDR p-value")
  header_y <- max(df$y) + header_gap
  y_limits <- c(min(df$y) - y_bottom_pad, header_y + y_top_pad)

  table_cells <- bind_rows(
    tibble(y = df$y, x = x_pos[1], hjust = 0.0, label = df$pathogen),
    tibble(y = df$y, x = x_pos[2], hjust = 0.5, label = df$group1),
    tibble(y = df$y, x = x_pos[3], hjust = 0.5, label = df$group0),
    tibble(y = df$y, x = x_pos[4], hjust = 0.5, label = df$diff_label),
    tibble(y = df$y, x = x_pos[5], hjust = 0.5, label = df$p_label),
    tibble(y = df$y, x = x_pos[6], hjust = 0.5, label = df$fdr_label)
  )

  header_df <- tibble(
    x = x_pos,
    y = header_y,
    hjust = c(0.0, rep(0.5, length(x_pos) - 1)),
    label = headers
  )

  table_plot <- ggplot() +
    geom_text(
      data = table_cells,
      aes(x = x, y = y, label = label, hjust = hjust),
      size = table_text_size,
      family = "serif",
      lineheight = 0.95
    ) +
    geom_text(
      data = header_df,
      aes(x = x, y = y, label = label, hjust = hjust),
      size = header_text_size,
      family = "serif",
      fontface = "bold"
    ) +
    scale_x_continuous(
      limits = c(min(x_pos) - 0.05, max(x_pos) + 0.45),
      expand = c(0, 0)
    ) +
    scale_y_continuous(
      limits = y_limits,
      expand = c(0, 0)
    ) +
    coord_cartesian(clip = "off") +
    theme_void() +
    theme(
      text = element_text(family = "serif"),
      plot.margin = margin(t = 4, r = 2, b = 2, l = 2)
    )

  x_max <- max(abs(c(df$lcl, df$ucl)), na.rm = TRUE)
  x_lim <- max(1, ceiling(x_max))

  forest_plot <- ggplot(df, aes(x = estimate, y = y)) +
    geom_vline(xintercept = 0, linetype = "dashed", linewidth = 0.45, color = "grey45") +
    geom_segment(
      aes(x = lcl, xend = ucl, y = y, yend = y),
      linewidth = 0.65,
      color = forest_color
    ) +
    geom_point(shape = 21, size = 2.1, fill = forest_color, color = "white", stroke = 0.25) +
    scale_x_continuous(
      limits = c(-x_lim, x_lim),
      breaks = pretty(c(-x_lim, x_lim), n = 6)
    ) +
    scale_y_continuous(
      limits = y_limits,
      breaks = df$y,
      labels = rep("", n_rows),
      expand = c(0, 0)
    ) +
    labs(x = "Difference in seroprevalence (percentage points)", y = NULL) +
    theme_classic(base_size = 9.5, base_family = "serif") +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.line.y = element_blank(),
      plot.margin = margin(t = 4, r = 10, b = 2, l = 5)
    )

  tag_plot <- ggplot() +
    annotate(
      "text",
      x = 0,
      y = 1,
      label = panel_tag,
      hjust = 0,
      vjust = 1,
      family = "serif",
      fontface = "bold",
      size = 4.8
    ) +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE, clip = "off") +
    theme_void() +
    theme(plot.margin = margin(t = 0, r = 0, b = 0, l = 2))

  panel_body <- table_plot + forest_plot + plot_layout(widths = c(0.68, 0.32))
  combined <- tag_plot / panel_body + plot_layout(heights = c(0.035, 0.965))

  list(plot = combined, n_rows = n_rows)
}

wsh_24m <- build_manuscript_panel_df(
  manuscript_df = manuscript_24m,
  intervention_name = "WASH",
  group_labels = c("No WASH", "WASH")
)

nutrition_24m <- build_manuscript_panel_df(
  manuscript_df = manuscript_24m,
  intervention_name = "Nutrition",
  group_labels = c("No Nutrition", "Nutrition")
)

wsh_12m <- build_manuscript_panel_df(
  manuscript_df = manuscript_12m,
  intervention_name = "WASH",
  group_labels = c("No WASH", "WASH")
)

nutrition_12m <- build_manuscript_panel_df(
  manuscript_df = manuscript_12m,
  intervention_name = "Nutrition",
  group_labels = c("No Nutrition", "Nutrition")
)

# Build the 4 panels
plot_24m_wash <- make_margin_panel(wsh_24m, panel_tag = "", 
                                   forest_color = cbpal_int[2])
plot_24m_nutrition <- make_margin_panel(nutrition_24m, panel_tag = "", 
                                        forest_color = cbpal_int[3])
plot_12m_wash <- make_margin_panel(wsh_12m, panel_tag = "", 
                                   forest_color = cbpal_int[2])
plot_12m_nutrition <- make_margin_panel(nutrition_12m, panel_tag = "", 
                                        forest_color = cbpal_int[3])

single_panel_height <- function(n_rows) {
  max(4.7, 0.31 * n_rows + 1.4)
}

patchwork_height <- function(n_rows) {
  max(6.8, 0.31 * n_rows + 2.3)
}

save_plot_files <- function(plot_obj, jpg_file, pdf_file, width, height) {
  ggsave(filename = jpg_file, plot = plot_obj, width = width, height = height, dpi = 600, bg = "white")
  ggsave(filename = pdf_file, plot = plot_obj, width = width, height = height, device = grDevices::pdf, bg = "white")
}

# Save individual panels (all four)
h_24m_wash <- single_panel_height(plot_24m_wash$n_rows)
h_24m_nutrition <- single_panel_height(plot_24m_nutrition$n_rows)
h_12m_wash <- single_panel_height(plot_12m_wash$n_rows)
h_12m_nutrition <- single_panel_height(plot_12m_nutrition$n_rows)

jpg_24m_wash <- file.path(out_fig_dir, "wash_24m_panel.jpg")
pdf_24m_wash <- file.path(out_fig_dir, "wash_24m_panel.pdf")
jpg_24m_nutrition <- file.path(out_fig_dir, "nutrition_24m_panel.jpg")
pdf_24m_nutrition <- file.path(out_fig_dir, "nutrition_24m_panel.pdf")
jpg_12m_wash <- file.path(out_fig_dir, "wash_12m_panel.jpg")
pdf_12m_wash <- file.path(out_fig_dir, "wash_12m_panel.pdf")
jpg_12m_nutrition <- file.path(out_fig_dir, "nutrition_12m_panel.jpg")
pdf_12m_nutrition <- file.path(out_fig_dir, "nutrition_12m_panel.pdf")

save_plot_files(plot_24m_wash$plot, jpg_24m_wash, pdf_24m_wash, width = 9, height = h_24m_wash)
save_plot_files(plot_24m_nutrition$plot, jpg_24m_nutrition, pdf_24m_nutrition, width = 9, height = h_24m_nutrition)
save_plot_files(plot_12m_wash$plot, jpg_12m_wash, pdf_12m_wash, width = 9, height = h_12m_wash)
save_plot_files(plot_12m_nutrition$plot, jpg_12m_nutrition, pdf_12m_nutrition, width = 9, height = h_12m_nutrition)


# Patchwork for 24m (WASH left, Nutrition right)
conditional_note_24m <- paste(
  "* Evidence for interaction between WASH and Nutrition.",
  "For S. enterica (LPS B,D) and S. stercoralis (NIE), conditional means and effects are reported",
  "(WASH vs Control in panel A; Nutrition vs Control in panel B)."
)

figure_24m <- (plot_24m_wash$plot | plot_24m_nutrition$plot) +
  plot_annotation(
    # title = "24 months",
    #caption = conditional_note_24m,
    theme = theme(
      plot.title = element_text(
        family = "serif",
        face = "bold",
        size = 14,
        hjust = 0
      )#,
      #plot.caption = element_text(
        #family = "serif",
        #size = 8.5,
        #hjust = 0
      #)
    )
  )

height_24m <- 6.3
jpg_24m <- file.path(out_fig_dir, "wash_nutrition_24m_patchwork.jpg")
pdf_24m <- file.path(out_fig_dir, "wash_nutrition_24m_patchwork.pdf")
save_plot_files(figure_24m, jpg_24m, pdf_24m, width = 20, height = height_24m)

# Patchwork for 12m (WASH left, Nutrition right)
figure_12m <- (plot_12m_wash$plot | plot_12m_nutrition$plot) +
  plot_annotation(
    #title = "Marginal seroprevalence by pathogen at 12 months",
    caption = conditional_note_24m,
    theme = theme(
      plot.title = element_text(
        family = "serif",
        face = "bold",
        size = 14,
        hjust = 0
      ),
      plot.caption = element_text(
        family = "serif",
        size = 8.5,
        hjust = 0
      )
    )
  )

height_12m <- 6 #patchwork_height(max(plot_12m_wash$n_rows, plot_12m_nutrition$n_rows))
jpg_12m <- file.path(out_fig_dir, "wash_nutrition_12m_patchwork.jpg")
pdf_12m <- file.path(out_fig_dir, "wash_nutrition_12m_patchwork.pdf")
save_plot_files(figure_12m, jpg_12m, pdf_12m, width = 20, height = height_12m)

message("Saved figure: ", jpg_24m)
message("Saved figure: ", pdf_24m)
message("Saved figure: ", jpg_12m)
message("Saved figure: ", pdf_12m)
message("Saved figure: ", jpg_24m_wash)
message("Saved figure: ", pdf_24m_wash)
message("Saved figure: ", jpg_24m_nutrition)
message("Saved figure: ", pdf_24m_nutrition)
message("Saved figure: ", jpg_12m_wash)
message("Saved figure: ", pdf_12m_wash)
message("Saved figure: ", jpg_12m_nutrition)
message("Saved figure: ", pdf_12m_nutrition)
