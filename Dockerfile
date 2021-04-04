FROM rocker/r-base:4.0.0

# Install common OS level dependencies for R packages
RUN apt-get update -qq && apt-get install -y \
  libssl-dev \
  libcurl4-gnutls-dev \
  libudunits2-dev

# Install dependencies for spatial analysis
RUN apt-get install -y \
   libgdal-dev \
   gdal-bin \
   libproj-dev \
   proj-data \
   proj-bin \
   libgeos-dev

# Install required R packages
RUN R -e "install.packages('purrr')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('tibble')"
RUN R -e "install.packages('stringr')"
RUN R -e "install.packages('readr')"
RUN R -e "install.packages('stringi')"
RUN R -e "install.packages('rgdal')"
RUN R -e "install.packages('sf')"
RUN R -e "install.packages('lwgeom')"

# Get all R scripts to the container
COPY R/distances.R distances.R
COPY R/separate_shape.R separate_shape.R
COPY R/join_segments.R join_segments.R
