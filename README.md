Extract a Canopy Height Model from LiDAR data
==============================
14 February, 2022

<br>

![Wytham Woods, Oxford](/reports/figures/angle_1.jpeg)

<br>

Code to extract and load DSM and DTM data from the UK's (National LIDAR Programme)[https://data.gov.uk/dataset/f0db0249-f17b-4036-9e65-309148c97ce4/national-lidar-programme]

<br>

Project Organization
------------

    ├── LICENSE
    ├── README.md          <- The top-level README.
    ├── data
    │   └── raw            <- The original .asc files. Data are program. extracted to
    │                         the relevant subfolders (DTM and DSM)  
    │
    ├── notebooks          <- .Rmd notebooks or .R scripts
    │   └── 0.1_data-ingest.Rmd 
    │                                 
    ├── reports            <- Generated analysis as HTML, PDF, LaTeX, etc.
    │   └── figures        <- Generated graphics and figures.
    │
    ├── renv.lock          <- The 'requirements' file for reproducing the environment,
    │                         generated with renv::snapshot()
    │
    ├── .Rprofile          <- Used to activate renv for new R sessions launched in the project.
    │
    ├── 01_gtit_maps.Rproj <- Shortcut to opening the project if using RStudio
    │
    ├── renv         
    │   └── activate.R     <- The activation script run by the project Rprofile.
    │
    ├── src                <- Source code for this project (called as modules from the notebook(s))
    │   └── read.R 
    │

<br>


#### To use this repository:

1. Navigate to the folder where you want to install the repository. Then type `git clone https://github.com/nilomr/wytham-canopy-model.git`

2. Open the `canopy-model.Rproj` file. The `renv` package, used for dependency management, will be automatically installed if it isn't already.

3. In your R console, type `renv::restore(lockfile = "renv.lock")`. This will install **the project's R dependencies**\
— you might still need to manually fix some unresolved system dependencies.

4. Open and run the `0.1_data-ingest.Rmd` notebook

<br>

#### To do
- [x] Add renv.lock
- [ ] Add contour and nestboxes
- [ ] test vegetation model (see (here)[https://environment.data.gov.uk/dataset/ecae3bef-1e1d-4051-887b-9dc613c928ec])



--------

<p><small>2022 | Nilo Merino Recalde | based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>.</small></p>
