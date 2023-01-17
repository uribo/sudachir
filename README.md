
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sudachir <a href='https://uribo.github.io/sudachir/'><img src='man/figures/logo.png' align="right" height="139" /></a>

SudachiR is an R version of
[Sudachi](https://github.com/WorksApplications/sudachi.rs), a Japanese
morphological analyzer.

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/sudachir)](https://CRAN.R-project.org/package=sudachir)
[![R build
status](https://github.com/uribo/sudachir/workflows/R-CMD-check/badge.svg)](https://github.com/uribo/sudachir/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

## Installation

You can install the released version of `{sudachir}` from CRAN with:

``` r
install.packages("sudachir")
```

and also, the developmment version from GitHub

``` r
if (!requireNamespace("remotes"))
  install.packages("remotes")

remotes::install_github("uribo/sudachir")
```

## Usage

### Set up ‘r-sudachipy’ environment

`{sudachir}` works with
[sudachipy](https://github.com/WorksApplications/sudachi.rs/tree/develop/python)
(\>= 0.6.\*) via the
[reticulate](https://github.com/rstudio/reticulate/) package.

To get started, it requires a Python environment that has sudachipy and
its dictionaries already installed and available.

This package provides a function `install_sudachipy` which helps users
prepare a Python virtual environment. The desired modules (`sudachipy`,
`sudachidict_core`, `pandas`) can be installed with this function, but
can also be installed manually.

``` r
library(reticulate)
library(sudachir)

if (!virtualenv_exists("r-sudachipy")) {
  install_sudachipy()
}

use_virtualenv("r-sudachipy", required = TRUE)
```

### Tokenize sentences

Use `tokenize_to_df` for tokenization.

``` r
txt <- c(
  "国家公務員は鳴門海峡に行きたい",
  "吾輩は猫である。\n名前はまだない。"
)
tokenize_to_df(txt)
#> # A tibble: 18 × 12
#>    doc_id token…¹ surface dicti…² norma…³ readi…⁴ 品詞1 品詞2 品詞3 品詞4 活用型
#>     <dbl>   <dbl> <chr>   <chr>   <chr>   <chr>   <chr> <chr> <chr> <chr> <chr> 
#>  1      1       1 国家公… 国家公… 国家公… コッカ… 名詞  普通… 一般  <NA>  <NA>  
#>  2      1       2 は      は      は      ハ      助詞  係助… <NA>  <NA>  <NA>  
#>  3      1       3 鳴門    鳴門    鳴門    ナルト  名詞  固有… 地名  一般  <NA>  
#>  4      1       4 海峡    海峡    海峡    カイキ… 名詞  普通… 一般  <NA>  <NA>  
#>  5      1       5 に      に      に      ニ      助詞  格助… <NA>  <NA>  <NA>  
#>  6      1       6 行き    行く    行く    イキ    動詞  非自… <NA>  <NA>  五段-…
#>  7      1       7 たい    たい    たい    タイ    助動… <NA>  <NA>  <NA>  助動… 
#>  8      2       1 吾輩    吾輩    我が輩  ワガハ… 代名… <NA>  <NA>  <NA>  <NA>  
#>  9      2       2 は      は      は      ハ      助詞  係助… <NA>  <NA>  <NA>  
#> 10      2       3 猫      猫      猫      ネコ    名詞  普通… 一般  <NA>  <NA>  
#> 11      2       4 で      だ      だ      デ      助動… <NA>  <NA>  <NA>  助動… 
#> 12      2       5 ある    ある    有る    アル    動詞  非自… <NA>  <NA>  五段-…
#> 13      2       6 。      。      。      。      補助… 句点  <NA>  <NA>  <NA>  
#> 14      2       1 名前    名前    名前    ナマエ  名詞  普通… 一般  <NA>  <NA>  
#> 15      2       2 は      は      は      ハ      助詞  係助… <NA>  <NA>  <NA>  
#> 16      2       3 まだ    まだ    未だ    マダ    副詞  <NA>  <NA>  <NA>  <NA>  
#> 17      2       4 ない    ない    無い    ナイ    形容… 非自… <NA>  <NA>  形容詞
#> 18      2       5 。      。      。      。      補助… 句点  <NA>  <NA>  <NA>  
#> # … with 1 more variable: 活用形 <chr>, and abbreviated variable names
#> #   ¹​token_id, ²​dictionary_form, ³​normalized_form, ⁴​reading_form
```

You can control which dictionary features are parsed using the
`col_select` argument.

``` r
tokenize_to_df(txt, col_select = 1:3) |>
  dplyr::glimpse()
#> Rows: 18
#> Columns: 9
#> $ doc_id          <dbl> 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
#> $ token_id        <dbl> 1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5
#> $ surface         <chr> "国家公務員", "は", "鳴門", "海峡", "に", "行き", "た…
#> $ dictionary_form <chr> "国家公務員", "は", "鳴門", "海峡", "に", "行く", "た…
#> $ normalized_form <chr> "国家公務員", "は", "鳴門", "海峡", "に", "行く", "た…
#> $ reading_form    <chr> "コッカコウムイン", "ハ", "ナルト", "カイキョウ", "ニ"…
#> $ 品詞1           <chr> "名詞", "助詞", "名詞", "名詞", "助詞", "動詞", "助動…
#> $ 品詞2           <chr> "普通名詞", "係助詞", "固有名詞", "普通名詞", "格助詞"…
#> $ 品詞3           <chr> "一般", NA, "地名", "一般", NA, NA, NA, NA, NA, "一般"…

tokenize_to_df(
  txt, 
  into = dict_features("en"),
  col_select = c("POS1", "POS2")
) |>
  dplyr::glimpse()
#> Rows: 18
#> Columns: 8
#> $ doc_id          <dbl> 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
#> $ token_id        <dbl> 1, 2, 3, 4, 5, 6, 7, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5
#> $ surface         <chr> "国家公務員", "は", "鳴門", "海峡", "に", "行き", "た…
#> $ dictionary_form <chr> "国家公務員", "は", "鳴門", "海峡", "に", "行く", "た…
#> $ normalized_form <chr> "国家公務員", "は", "鳴門", "海峡", "に", "行く", "た…
#> $ reading_form    <chr> "コッカコウムイン", "ハ", "ナルト", "カイキョウ", "ニ"…
#> $ POS1            <chr> "名詞", "助詞", "名詞", "名詞", "助詞", "動詞", "助動…
#> $ POS2            <chr> "普通名詞", "係助詞", "固有名詞", "普通名詞", "格助詞"…
```

The `as_phrase` function can tidy up tokens and the first part-of-speech
informations into a list of named tokens. Also, you can use the `form`
function as a shorthand of `tokenize_to_df(txt) |> as_phrase()`.

``` r
tokenize_to_df(txt) |> as_phrase(type = "surface")
#> $`1`
#>         名詞         助詞         名詞         名詞         助詞         動詞 
#> "国家公務員"         "は"       "鳴門"       "海峡"         "に"       "行き" 
#>       助動詞 
#>       "たい" 
#> 
#> $`2`
#>   代名詞     助詞     名詞   助動詞     動詞 補助記号     名詞     助詞 
#>   "吾輩"     "は"     "猫"     "で"   "ある"     "。"   "名前"     "は" 
#>     副詞   形容詞 補助記号 
#>   "まだ"   "ない"     "。"

form(txt, type = "surface")
#> $`1`
#>         名詞         助詞         名詞         名詞         助詞         動詞 
#> "国家公務員"         "は"       "鳴門"       "海峡"         "に"       "行き" 
#>       助動詞 
#>       "たい" 
#> 
#> $`2`
#>   代名詞     助詞     名詞   助動詞     動詞 補助記号     名詞     助詞 
#>   "吾輩"     "は"     "猫"     "で"   "ある"     "。"   "名前"     "は" 
#>     副詞   形容詞 補助記号 
#>   "まだ"   "ない"     "。"
form(txt, type = "normalized")
#> $`1`
#>         名詞         助詞         名詞         名詞         助詞         動詞 
#> "国家公務員"         "は"       "鳴門"       "海峡"         "に"       "行く" 
#>       助動詞 
#>       "たい" 
#> 
#> $`2`
#>   代名詞     助詞     名詞   助動詞     動詞 補助記号     名詞     助詞 
#> "我が輩"     "は"     "猫"     "だ"   "有る"     "。"   "名前"     "は" 
#>     副詞   形容詞 補助記号 
#>   "未だ"   "無い"     "。"
form(txt, type = "dictionary")
#> $`1`
#>         名詞         助詞         名詞         名詞         助詞         動詞 
#> "国家公務員"         "は"       "鳴門"       "海峡"         "に"       "行く" 
#>       助動詞 
#>       "たい" 
#> 
#> $`2`
#>   代名詞     助詞     名詞   助動詞     動詞 補助記号     名詞     助詞 
#>   "吾輩"     "は"     "猫"     "だ"   "ある"     "。"   "名前"     "は" 
#>     副詞   形容詞 補助記号 
#>   "まだ"   "ない"     "。"
form(txt, type = "reading")
#> $`1`
#>               名詞               助詞               名詞               名詞 
#> "コッカコウムイン"               "ハ"           "ナルト"       "カイキョウ" 
#>               助詞               動詞             助動詞 
#>               "ニ"             "イキ"             "タイ" 
#> 
#> $`2`
#>     代名詞       助詞       名詞     助動詞       動詞   補助記号       名詞 
#> "ワガハイ"       "ハ"     "ネコ"       "デ"     "アル"       "。"   "ナマエ" 
#>       助詞       副詞     形容詞   補助記号 
#>       "ハ"     "マダ"     "ナイ"       "。"

# This is the fastest equivalent if no part-of-speech features is needed at all.
as_tokens(txt) |> as_phrase("surface", pos = FALSE)
#> $`1`
#> [1] "国家公務員" "は"         "鳴門"       "海峡"       "に"        
#> [6] "行き"       "たい"      
#> 
#> $`2`
#>  [1] "吾輩" "は"   "猫"   "で"   "ある" "。"   "名前" "は"   "まだ" "ない"
#> [11] "。"
```

### Change split mode

``` r
tokenize_to_df(txt, mode = "B") |>
  as_phrase("surface", pos = FALSE)
#> $`1`
#> [1] "国家"   "公務員" "は"     "鳴門"   "海峡"   "に"     "行き"   "たい"  
#> 
#> $`2`
#>  [1] "吾輩" "は"   "猫"   "で"   "ある" "。"   "名前" "は"   "まだ" "ない"
#> [11] "。"

tokenize_to_df(txt, mode = "A") |>
  as_phrase("surface", pos = FALSE)
#> $`1`
#> [1] "国家" "公務" "員"   "は"   "鳴門" "海峡" "に"   "行き" "たい"
#> 
#> $`2`
#>  [1] "吾輩" "は"   "猫"   "で"   "ある" "。"   "名前" "は"   "まだ" "ない"
#> [11] "。"
```

### Change dictionary edition

You can touch dictionary options using the `rebuild_tokenizer` function.

``` r
if (py_module_available("sudachidict_full")) {
  tokenizer_full <- rebuild_tokenizer(mode = "C", dict_type = "full")
  tokenize_to_df(txt, instance = tokenizer_full) |>
    as_phrase("surface", pos = FALSE)
}
#> $`1`
#> [1] "国家公務員" "は"         "鳴門海峡"   "に"         "行き"      
#> [6] "たい"      
#> 
#> $`2`
#> [1] "吾輩は猫である" "。"             "名前"           "は"            
#> [5] "まだ"           "ない"           "。"
```
