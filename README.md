
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

``` r
library(reticulate)
library(sudachir)
```

### Setup r-sudachipy environment

``` r
install_sudachipy()
```

``` r
use_virtualenv("r-sudachipy", required = TRUE)
```

### Tokenize

``` r
txt <- c(
  "国家公務員はかつ丼を食べたい",
  "メロスは激怒した。",
  "吾輩は猫である。"
)
(ret <- tokenize_to_df(txt, mode = "C"))
#> # A tibble: 18 × 12
#>    doc_id token…¹ surface dicti…² norma…³ readi…⁴ 品詞1 品詞2 品詞3 品詞4 活用型
#>     <dbl>   <dbl> <chr>   <chr>   <chr>   <chr>   <chr> <chr> <chr> <chr> <chr> 
#>  1      1       1 国家公… 国家公… 国家公… コッカ… 名詞  普通… 一般  <NA>  <NA>  
#>  2      1       2 は      は      は      ハ      助詞  係助… <NA>  <NA>  <NA>  
#>  3      1       3 かつ丼  かつ丼  カツ丼  カツド… 名詞  普通… 一般  <NA>  <NA>  
#>  4      1       4 を      を      を      ヲ      助詞  格助… <NA>  <NA>  <NA>  
#>  5      1       5 食べ    食べる  食べる  タベ    動詞  一般  <NA>  <NA>  下一… 
#>  6      1       6 たい    たい    たい    タイ    助動… <NA>  <NA>  <NA>  助動… 
#>  7      2       1 メロス  メロス  メロス  メロス  名詞  普通… 一般  <NA>  <NA>  
#>  8      2       2 は      は      は      ハ      助詞  係助… <NA>  <NA>  <NA>  
#>  9      2       3 激怒    激怒    激怒    ゲキド  名詞  普通… サ変… <NA>  <NA>  
#> 10      2       4 し      する    為る    シ      動詞  非自… <NA>  <NA>  サ行… 
#> 11      2       5 た      た      た      タ      助動… <NA>  <NA>  <NA>  助動… 
#> 12      2       6 。      。      。      。      補助… 句点  <NA>  <NA>  <NA>  
#> 13      3       1 吾輩    吾輩    我が輩  ワガハ… 代名… <NA>  <NA>  <NA>  <NA>  
#> 14      3       2 は      は      は      ハ      助詞  係助… <NA>  <NA>  <NA>  
#> 15      3       3 猫      猫      猫      ネコ    名詞  普通… 一般  <NA>  <NA>  
#> 16      3       4 で      だ      だ      デ      助動… <NA>  <NA>  <NA>  助動… 
#> 17      3       5 ある    ある    有る    アル    動詞  非自… <NA>  <NA>  五段-…
#> 18      3       6 。      。      。      。      補助… 句点  <NA>  <NA>  <NA>  
#> # … with 1 more variable: 活用形 <chr>, and abbreviated variable names
#> #   ¹​token_id, ²​dictionary_form, ³​normalized_form, ⁴​reading_form
```

``` r
form(txt, type = "surface", pos = TRUE)
#> $`1`
#>         名詞         助詞         名詞         助詞         動詞       助動詞 
#> "国家公務員"         "は"     "かつ丼"         "を"       "食べ"       "たい" 
#> 
#> $`2`
#>     名詞     助詞     名詞     動詞   助動詞 補助記号 
#> "メロス"     "は"   "激怒"     "し"     "た"     "。" 
#> 
#> $`3`
#>   代名詞     助詞     名詞   助動詞     動詞 補助記号 
#>   "吾輩"     "は"     "猫"     "で"   "ある"     "。"
form(txt, type = "normalized", pos = FALSE)
#> $`1`
#> [1] "国家公務員" "は"         "カツ丼"     "を"         "食べる"    
#> [6] "たい"      
#> 
#> $`2`
#> [1] "メロス" "は"     "激怒"   "為る"   "た"     "。"    
#> 
#> $`3`
#> [1] "我が輩" "は"     "猫"     "だ"     "有る"   "。"
form(txt, type = "dictionary", pos = FALSE)
#> $`1`
#> [1] "国家公務員" "は"         "かつ丼"     "を"         "食べる"    
#> [6] "たい"      
#> 
#> $`2`
#> [1] "メロス" "は"     "激怒"   "する"   "た"     "。"    
#> 
#> $`3`
#> [1] "吾輩" "は"   "猫"   "だ"   "ある" "。"
form(txt, type = "reading", pos = FALSE)
#> $`1`
#> [1] "コッカコウムイン" "ハ"               "カツドン"         "ヲ"              
#> [5] "タベ"             "タイ"            
#> 
#> $`2`
#> [1] "メロス" "ハ"     "ゲキド" "シ"     "タ"     "。"    
#> 
#> $`3`
#> [1] "ワガハイ" "ハ"       "ネコ"     "デ"       "アル"     "。"
```
