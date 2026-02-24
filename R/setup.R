options(
  tidyverse.quiet = TRUE,
  propensity.quiet = TRUE,
  tipr.verbose = FALSE,
  htmltools.dir.version = FALSE,
  width = 55,
  digits = 4,
  # Use default colors if ggokabeito is not available
  ggplot2.discrete.colour = if(requireNamespace("ggokabeito", quietly = TRUE)) ggokabeito::palette_okabe_ito() else "viridis",
  ggplot2.discrete.fill = if(requireNamespace("ggokabeito", quietly = TRUE)) ggokabeito::palette_okabe_ito() else "viridis",
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis",
  book.base_family = "sans",
  book.base_size = 14
)

library(ggplot2)

theme_set(
  theme_minimal(
    base_size = getOption("book.base_size"),
    base_family = getOption("book.base_family")
  ) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
)

theme_dag <- function() {
  if(requireNamespace("ggdag", quietly = TRUE)) {
    ggdag::theme_dag(base_family = getOption("book.base_family"))
  } else {
    theme_minimal(base_family = getOption("book.base_family"))
  }
}

geom_dag_label_repel <- function(..., seed = 10) {
  if(requireNamespace("ggdag", quietly = TRUE)) {
    ggdag::geom_dag_label_repel(
      aes(x, y, label = label),
      box.padding = 3.5,
      inherit.aes = FALSE,
      max.overlaps = Inf,
      family = getOption("book.base_family"),
      seed = seed,
      label.size = NA,
      label.padding = 0.1,
      size = getOption("book.base_size") / 3,
      ...
    )
  } else {
    # Fallback to regular geom_text if ggdag is not available
    geom_text(aes(x, y, label = label), inherit.aes = FALSE, ...)
  }
}

est_ci <- function(.df, rsample = FALSE) {
  if (!is.data.frame(.df) && is.numeric(.df)) {
    return(
      glue::glue(
        "{round(.df[[1]], digits = 1)} (95% CI {round(.df[[2]], digits = 1)}, {round(.df[[3]], digits = 1)})"
      )
    )
  }

  if (rsample) {
    glue::glue(
      "{round(.df$.estimate, digits = 1)} (95% CI {round(.df$.lower, digits = 1)}, {round(.df$.upper, digits = 1)})"
    )
  } else {
    glue::glue("{.df$estimate} (95% CI {.df$conf.low}, {.df$conf.high})")
  }
}

# based on https://github.com/hadley/r-pkgs/blob/main/common.R
status <- function(type) {
  status <- switch(
    type,
    unstarted = "아직 시작되지 않았지만, 로드맵에 포함되어 있으니 걱정 마세요",
    polishing = "기반 내용은 작성되었으나 여전히 수정이 진행 중입니다",
    wip = "활발히 작업 중이며 구조가 변경되거나 수정될 수 있습니다. 또한 내용이 불완전할 수 있습니다",
    complete = "거의 완성되었으나, 작은 수정이나 문구 교정이 있을 수 있습니다",
    stop("Invalid `type`", call. = FALSE)
  )

  class <- switch(
    type,
    complete = ,
    polishing = "callout-note",
    wip = "callout-warning",
    unstarted = "callout-warning"
  )

  knitr::asis_output(paste0(
    "::: ",
    class,
    "\n",
    "## 작업 진행 중 🚧\n",
    "여러분은 현재 작성 중인 *R을 이용한 인과 추론*의 초판본을 읽고 계십니다. ",
    "이 장은 ",
    status,
    ". \n",
    ":::\n"
  ))
}
