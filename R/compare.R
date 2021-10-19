library("tidyverse")
library("ggrepel")


# comparing computing times -----------------------------------------------

computing_times_df <- 
  rbind(
    read_csv(here::here("data/jdx", "computing_times.csv")) %>% mutate(test = "jdx"),
    read_csv(here::here("data/java_to_dt", "computing_times.csv")) %>% mutate(test = "java_to_dt")
  )
    
computing_times_df %>%
  select(elapsed, operation, test) %>%
  pivot_wider(names_from = test, values_from = elapsed) %>%
  ggplot(aes(x=jdx, y=java_to_dt)) +
  geom_point() +
  geom_text_repel(aes(label=operation)) +
  geom_abline() +
  coord_equal() +
  scale_x_continuous(breaks = seq(0, 7, 0.5)) +
  scale_y_continuous(breaks = seq(0, 7, 0.5)) +
  expand_limits(x = c(0, 7), y = c(0, 7))


# comparing results -------------------------------------------------------
ttm_jdx <- read_csv(here::here("data/jdx", "travel_time_matrix.csv")) %>% select(-execution_time)
ttm_jtodt <- read_csv(here::here("data/java_to_dt", "travel_time_matrix.csv")) %>% select(-execution_time)
all(ttm_jdx == ttm_jtodt)

compare_data <- function(filename) {
  data_jdx <- read_csv(here::here("data/jdx", filename))
  data_jtodt <- read_csv(here::here("data/java_to_dt", filename))
  
  if ("execution_time" %in% colnames(data_jdx)) { data_jdx <- select(data_jdx, -execution_time) }
  if ("execution_time" %in% colnames(data_jtodt)) { data_jtodt <- select(data_jtodt, -execution_time) }
  
  return(all(ttm_jdx == ttm_jtodt))
}

compare_data("travel_time_matrix.csv")
compare_data("detailed_itineraries.csv")
compare_data("accessibility.csv")
compare_data("street_vertices.csv")
compare_data("street_edges.csv")
compare_data("transit_stops.csv")
compare_data("transit_routes.csv")
compare_data("snap.csv")



