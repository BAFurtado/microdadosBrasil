<!-- README.md is generated from README.Rmd. Please edit that file -->
microadadosBrasil
=================

work in progress
================

-   under revision for typos
-   vignettes and Portuguese documentation soon

Description
===========

&lt;&lt;&lt;&lt;&lt;&lt;&lt; HEAD this package contains functions to read most commonly used Brazilian microdata easily and quickly. Importing Brazilian microdata can be tedious. Most data is provided in fixed width files (fwf) with import instructions only for SAS and SPSS. Data usually comes subdivided by state (UF) or macro regions (regiões). And filenames can vary, for the same dataset overtime. `microdadoBrasil` handles all these idiosyncrasies for you. In the background the package is running `readr` for fwf data and `data.table` for .csv data. Therefore reading is reasonably fast. ======= this package contains functions to read most commonly used Brazilian microdata easily and quickly. Importing Brazilian microdata can be tedious. Most data is provided in fixed width files (fwf) with import instructions only for SAS and SPSS. Data usually comes subdivided by state (UF) or macro regions (regiões). And filenames can vary, for the same dataset overtime. `microdadoBrasil` handles all these idiosyncrasies for you. In the background the package is running `readr` for fwf data and `data.table` for .csv data. Therefore reading is reasonably fast. &gt;&gt;&gt;&gt;&gt;&gt;&gt; 166f4519d10a502f84146fd9dd802e0ed35c07bc

Currently the package includes import functions for:

-   CENSO DEMOGRÁFICO: 2000 (soon to be expanded to 2010 and 1991)
-   POF
-   CENSO ESCOLAR, all years
-   CENSO DA EDUCAÇÃO SUPERIOR, all years

To be added soon:

-   RAIS, de-identified version,
-   download functions
-   variable name harmonization
-   Support for data not fitting into memory.

Installation
------------

``` r
# install.packages("devtools")
devtools::install_github("lucasmation/microdadosBrasil")
library('microdadosBrasil')
```

Usage
-----

``` r
#Censo Demográfico 2000
#after having downloaded the data to the root directory, and unziped to root run
d <- read_CENSO('domicilios',2005)
d <- read_CENSO('pessoas',2005)


# Censo Escolar
#download_CensoEscolar(2005) . Not yet available. In the future will download and unzip ( .rar files still need manual descompactation)
d <- read_CensoEscolar('matriculas',2005)
d <- read_CensoEscolar('escola',2005,harmonize_varnames=T)
```

Related efforts
---------------

This package is highly influenced by similar efforts, which are great time savers, vastly used often unrecognized:

-   Anthony Damico's [scripts to read most IBGE surveys](http://www.asdfree.com/). Great if you your data does not fit into memory and you want speed when working with complex survey design data.
-   [Data Zoom](http://www.econ.puc-rio.br/datazoom/) by Gustavo Gonzaga, Claudio Ferraz and Juliano Assunção. Similar ease of use and harmonization of Brazilian microdada for Stata.
-   [dicionariosIBGE](https://cran.r-project.org/web/packages/dicionariosIBGE/index.html), by Alexandre Rademaker. A set of data.frame containing the information from SAS import dictionaries for IBGE datasets.
-   [IPUMS](https://international.ipums.org/international/). Harmonization of Census data from several countries, including Brasil. Import functions for R, Stata, SAS and SPSS.

`microdadosBrasil` differs from those packages in that it:

-   updates import functions to more recent years
-   includes non-IBGE data, such as INEP Education Census and MTE RAIS (de-identified)
-   separates import code from dataset specific metadata, as explained bellow.

Design principles
-----------------

The main design principle was separating details of each dataset in each year - such as folder structure, data files and import dictionaries of the of original data - into metadata tables (saved as csv files at the `extdata` folder). The elements in these tables, along with list of import dictionaries extracted from the SAS import instructions from the data provider, serve as parameters to import a dataset for a specific year. This separation of dataset specific details from the actual code makes code short and easier to extend to new packages.

ergonomics over speed (develop)
