# redlistr_intro_notebook

Teaching material focused on the `redlistr` R package using a lightweight Reef ecosystem demo.

## Main notebook
- `Intro_to_redlistRpackipynb.ipynb`

## Scope
- Core `redlistr` workflows: AOO, EOO, area change, decline, uncertainty, extrapolation help
- Minimal `rredlist` usage: one optional API connectivity check using `IUCN_REDLIST_KEY`
- Synthetic raster data (no external files required); the notebook/script will also load a small built-in example raster if `data/reef_sample.tif` is present, making it easy to swap in your own GeoTIFF later

The notebook includes theory and package context.  The `redlistr` package is on CRAN:
https://cran.r-project.org/web/packages/redlistr/index.html (see the reference manual for a full
function list: https://cran.r-project.org/web/packages/redlistr/refman/redlistr.html).


## Usage

1. **Install prerequisites**: ensure you have R (>=4.1) and the following packages installed in R:
   ```r
   install.packages(c("terra","raster","ggplot2","rredlist","redlistr","rmarkdown"))
   ```
   Optionally supply an `IUCN_REDLIST_KEY` environment variable if you want to test the API call.

2. **Generate sample data and run the analysis**:
   ```sh
   Rscript scripts/notebook_code.R
   ```
   This creates or updates `data/reef_sample.tif` and produces console output confirming each
   function executed successfully.

3. **Render the teaching notebook to HTML**:
   ```sh
   Rscript -e "rmarkdown::render('Intro_to_redlistRpackipynb.ipynb', \
      output_format='html_document', output_file='docs/index.html')"
   ```
   The resulting page is suitable for publication via GitHub Pages.

4. **Publish via GitHub Pages** (optional):
   ```sh
   bash scripts/publish_pages.sh
   ```
   This pushes `docs/` to the `gh-pages` branch.  Enable Pages in your repository settings if
   not already active.

The codebase is designed so that the R script is the single source of truth; cells in the
notebook mirror the commands in `scripts/notebook_code.R`.

