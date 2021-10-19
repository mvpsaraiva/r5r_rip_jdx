options(java.parameters = '-Xmx16384m')

### Install r5r 0.6-0 from GitHub dev branch
# devtools::install_github("ipeaGIT/r5r", subdir = "r-package", ref = "dev")


# initialize --------------------------------------------------------------

library(r5r)
library(data.table)
library(tidyverse)

set.seed(19102021)

# build transport network
data_path <- system.file("extdata/poa", package = "r5r")
r5r_core <- setup_r5(data_path = data_path, verbose = TRUE)

# load origin/destination points

departure_datetime <- as.POSIXct("13-05-2019 14:00:00", format = "%d-%m-%Y %H:%M:%S")

poi <- read.csv(file.path(data_path, "poa_points_of_interest.csv"))
points <- read.csv(file.path(data_path, "poa_hexgrid.csv"))
dest <- points



# run functons ------------------------------------------------------------

r5r_core$setBenchmark(TRUE)
t_access <- system.time(
  access <- accessibility(r5r_core,
                          origins = points,
                          destinations = dest,
                          opportunities_colname = "schools",
                          mode = "WALK",
                          cutoffs = c(25, 30),
                          max_trip_duration = 60,
                          time_window = 60,
                          verbose = FALSE)
)

t_ttm <- system.time(
  ttm <- travel_time_matrix(r5r_core, origins = points,
                            destinations = dest,
                            mode = c("WALK", "TRANSIT"),
                            max_trip_duration = 60,
                            max_walk_dist = 800,
                            time_window = 30,
                            percentiles = c(25, 50, 75),
                            verbose = FALSE)
)
#
t_dit <- system.time(
  dit <- detailed_itineraries(r5r_core,
                            origins = sample_n(points, 150),
                          destinations = sample_n(points, 150),
                          mode = c("WALK", "TRANSIT"),
                          max_trip_duration = 60,
                          max_walk_dist = 800,
                          max_bike_dist = 800,
                          verbose = FALSE,
                          drop_geometry = FALSE,
                          shortest_path = FALSE,
                          departure_datetime = departure_datetime)
)

t_street <- system.time(street_net <- street_network_to_sf(r5r_core))
t_transit <- system.time(transit_net <- transit_network_to_sf(r5r_core))
t_snap <- system.time(snap <- find_snap(r5r_core, points))


# prepare benchmarks output -----------------------------------------------

computing_times_df <- rbind(
  t(data.matrix(t_access)) %>% as.data.frame() %>% mutate(operation = "accessibility"),
  t(data.matrix(t_ttm)) %>% as.data.frame() %>% mutate(operation = "travel_time_matrix"),
  t(data.matrix(t_dit)) %>% as.data.frame() %>% mutate(operation = "detailed_itineraries"),
  t(data.matrix(t_street)) %>% as.data.frame() %>% mutate(operation = "street_network_to_sf"),
  t(data.matrix(t_transit)) %>% as.data.frame() %>% mutate(operation = "transit_network_to_sf"),
  t(data.matrix(t_snap)) %>% as.data.frame() %>% mutate(operation = "find_snap")
)


# save results ------------------------------------------------------------
write_csv(computing_times_df, here::here("data/java_to_dt", "computing_times.csv"))
write_csv(ttm, here::here("data/java_to_dt", "travel_time_matrix.csv"))
write_csv(access, here::here("data/java_to_dt", "accessibility.csv"))
write_csv(dit, here::here("data/java_to_dt", "detailed_itineraries.csv"))

write_csv(street_net$vertices, here::here("data/java_to_dt", "street_vertices.csv"))
write_csv(street_net$edges, here::here("data/java_to_dt", "street_edges.csv"))

write_csv(transit_net$stops, here::here("data/java_to_dt", "transit_stops.csv"))
write_csv(transit_net$routes, here::here("data/java_to_dt", "transit_routes.csv"))

write_csv(snap, here::here("data/java_to_dt", "snap.csv"))

