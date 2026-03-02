# rredlist Education Material

This guide is for learning `rredlist` by function group while keeping your API key private.

## 1) Secure setup (key hidden, examples still runnable)

### Personal machine (recommended)
1. Install package:
```r
install.packages("rredlist")
```
2. Add key once with:
```r
rredlist::rl_use_iucn()
```
3. Restart R and verify:
```r
Sys.getenv("IUCN_REDLIST_KEY")
rredlist::rl_api_version()
```

### Share with others safely
- Keep secrets out of git (`.Renviron`, `.env` are gitignored).
- Commit only `.env.example` with placeholder text.
- Ask learners to create their own `.env` from `.env.example`.
- Use `scripts/setup_rredlist_key.R` in notebooks/scripts.

```r
source("scripts/setup_rredlist_key.R")
init_rredlist()
library(rredlist)
```

### Google Colab
Use a Colab Secret named `IUCN_REDLIST_KEY`, then in notebook:
```r
Sys.setenv(IUCN_REDLIST_KEY = Sys.getenv("IUCN_REDLIST_KEY"))
library(rredlist)
rl_api_version()
```

## 2) Learning path by function group

Use this starter once:
```r
source("scripts/setup_rredlist_key.R")
init_rredlist()
library(rredlist)
```

### Group A: Assessment retrieval
Main functions: `rl_assessment()`, `rl_assessment_list()`, `rl_species_latest()`, `rl_sis_latest()`, `rl_assessment_extract()`

Baseline:
```r
latest <- rl_species_latest("Gorilla", "gorilla")
str(latest, max.level = 2)
```

Practical:
```r
species <- data.frame(genus = c("Gorilla", "Phascolarctos"),
                      species = c("gorilla", "cinereus"))
rows <- lapply(seq_len(nrow(species)), function(i) {
  x <- rl_species_latest(species$genus[i], species$species[i])
  data.frame(genus = species$genus[i],
             species = species$species[i],
             category = x$category,
             year_published = x$year_published)
})
do.call(rbind, rows)
```

### Group B: Taxonomy queries
Main functions: `rl_species()`, `rl_sis()`, `rl_family()`, `rl_order()`, `rl_class()`, `rl_phylum()`, `rl_kingdom()`

Baseline:
```r
x <- rl_species("Gorilla", "gorilla")
nrow(x$assessments)
```

Practical:
```r
birds <- rl_class("Aves")
head(birds$assessments)
```

### Group C: Habitats and systems
Main functions: `rl_habitats()`, `rl_systems()`

Baseline:
```r
hab <- rl_habitats()
str(hab, max.level = 1)
```

Practical:
```r
terr <- rl_systems("terrestrial", all = FALSE)
head(terr$assessments)
```

### Group D: Geography filters
Main functions: `rl_countries()`, `rl_realms()`, `rl_scopes()`, `rl_faos()`

Baseline:
```r
countries <- rl_countries()
str(countries, max.level = 1)
```

Practical:
```r
au <- rl_countries("AU", all = FALSE)
head(au$assessments)
```

### Group E: Conservation action and research
Main functions: `rl_actions()`, `rl_research()`

Baseline:
```r
actions <- rl_actions()
head(actions$conservation_actions)
```

Practical:
```r
inv <- rl_actions("2_2", all = FALSE)
head(inv$assessments)
```

### Group F: Threat and pressure details
Main functions: `rl_categories()`, `rl_threats()`, `rl_stresses()`, `rl_use_and_trade()`, `rl_pop_trends()`

Baseline:
```r
thr <- rl_threats()
str(thr, max.level = 1)
```

Practical:
```r
trends <- rl_pop_trends()
head(trends$population_trends)
```

### Group G: Special taxon sets
Main functions: `rl_comp_groups()`, `rl_growth_forms()`, `rl_extinct()`, `rl_extinct_wild()`, `rl_green()`

Baseline:
```r
extinct <- rl_extinct()
str(extinct, max.level = 1)
```

Practical:
```r
green <- rl_green()
str(green, max.level = 1)
```

### Group H: Metadata and visualization helpers
Main functions: `rl_sp_count()`, `rl_version()`, `rl_api_version()`, `rl_citation()`, `scale_*_iucn()`

Baseline:
```r
rl_version()
rl_api_version()
rl_citation()
```

Practical:
```r
library(ggplot2)
df <- data.frame(category = c("LC", "NT", "VU", "EN", "CR"),
                 n = c(120, 35, 22, 11, 4))

ggplot(df, aes(category, n, fill = category)) +
  geom_col() +
  scale_fill_iucn() +
  theme_minimal()
```

## 3) Teaching checklist

For each lesson:
1. Run one baseline call.
2. Inspect output with `str()` and `names()`.
3. Build one small table from returned fields.
4. Add one domain question (example: "which categories dominate in this region?").
5. Record citation using `rl_citation()`.

## 4) Important notes

- Endpoint field names can vary; inspect results before hard-coding selectors.
- API has rate limits; keep loops small and cache results for classes.
- `rredlist` is the API client; `redlistr` is a separate assessment toolbox.
