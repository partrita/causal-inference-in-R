
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Causal Inference in R

<!-- badges: start -->
<!-- badges: end -->

This repository contains the source code for the book *Causal Inference
in R.*

## Installation

This project uses [pixi](https://pixi.sh/) for dependency management. After cloning this repository, you can install all dependencies with:

```bash
pixi install
```

Alternatively, you can install the R package dependencies manually with:

``` r
# install.packages("remotes")
remotes::install_deps(dependencies = TRUE)
```

We use [Quarto](https://quarto.org/) to render this book.

## Development

To render the book locally:

```bash
pixi run render
```

To preview the book with live reload:

```bash
pixi run preview
```

## Deployment

This book is automatically deployed to GitHub Pages when changes are pushed to the main branch. The deployment is handled by GitHub Actions using pixi for dependency management.
