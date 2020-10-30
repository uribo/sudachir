
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sudachir <a href='https://uribo.github.io/sudachir/'><img src='man/figures/logo.png' align="right" height="139" /></a>

SudachiR is a R version of
[Sudachi](https://github.com/WorksApplications/Sudachi), a Japanese
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

This package is not yet on CRAN, but can be installed from GitHub with:

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
use_condaenv(condaenv = "r-sudachipy", required = TRUE)
```

### Tokenize

``` r
m <- 
  tokenizer("高輪ゲートウェイ駅", mode = "A")
#> Parsed to 3 tokens

for (i in seq_len(py_len(m[[1]])) - 1) {
  print(m[[1]][i])
}
#> 高輪
#> ゲートウェイ
#> 駅

m <- 
  tokenizer("高輪ゲートウェイ駅", mode = "C")
#> Parsed to 1 token

for (i in seq_len(py_len(m[[1]])) - 1) {
  print(m[[1]][i])
}
#> 高輪ゲートウェイ駅
```

``` r
txt <- c("国家公務員はかつ丼を食べたい", 
         "メロスは激怒した。",
         "吾輩は猫である。")

tokenize_to_df(txt, mode = "C")
#> Parsed to 6 tokens
#> Parsed to 6 tokens
#> Parsed to 6 tokens
#> # A tibble: 18 x 11
#>    id    surface dic_form normalized_form reading 品詞1 品詞2 品詞3 品詞4 活用型
#>    <chr> <chr>   <chr>    <chr>           <chr>   <chr> <chr> <chr> <chr> <chr> 
#>  1 1     国家公務員… 国家公務員… 国家公務員      コッカコウム… 名詞  普通名詞… 一般  <NA>  <NA>  
#>  2 1     は      は       は              ハ      助詞  係助詞… <NA>  <NA>  <NA>  
#>  3 1     かつ丼  かつ丼   カツ丼          カツドン… 名詞  普通名詞… 一般  <NA>  <NA>  
#>  4 1     を      を       を              ヲ      助詞  格助詞… <NA>  <NA>  <NA>  
#>  5 1     食べ    食べる   食べる          タベ    動詞  一般  <NA>  <NA>  下一段-バ…
#>  6 1     たい    たい     たい            タイ    助動詞… <NA>  <NA>  <NA>  助動詞-タ…
#>  7 2     メロス  メロス   メロス          メロス  名詞  普通名詞… 一般  <NA>  <NA>  
#>  8 2     は      は       は              ハ      助詞  係助詞… <NA>  <NA>  <NA>  
#>  9 2     激怒    激怒     激怒            ゲキド  名詞  普通名詞… サ変可能… <NA>  <NA>  
#> 10 2     し      する     為る            シ      動詞  非自立可… <NA>  <NA>  サ行変格…
#> 11 2     た      た       た              タ      助動詞… <NA>  <NA>  <NA>  助動詞-タ…
#> 12 2     。      。       。              。      補助記号… 句点  <NA>  <NA>  <NA>  
#> 13 3     吾輩    吾輩     我が輩          ワガハイ… 代名詞… <NA>  <NA>  <NA>  <NA>  
#> 14 3     は      は       は              ハ      助詞  係助詞… <NA>  <NA>  <NA>  
#> 15 3     猫      猫       猫              ネコ    名詞  普通名詞… 一般  <NA>  <NA>  
#> 16 3     で      だ       だ              デ      助動詞… <NA>  <NA>  <NA>  助動詞-ダ…
#> 17 3     ある    ある     有る            アル    動詞  非自立可… <NA>  <NA>  五段-ラ行…
#> 18 3     。      。       。              。      補助記号… 句点  <NA>  <NA>  <NA>  
#> # … with 1 more variable: 活用形 <chr>
```

``` r
form("東京都へ行く", mode = "B", type = "dictionary")
#> Parsed to 3 tokens
#> [[1]]
#>     名詞     助詞     動詞 
#> "東京都"     "へ"   "行く"

form("国家公務員はかつ丼を食べたい", mode = "C", type = "normalized", pos = TRUE)
#> Parsed to 6 tokens
#> [[1]]
#>         名詞         助詞         名詞         助詞         動詞       助動詞 
#> "国家公務員"         "は"     "カツ丼"         "を"     "食べる"       "たい"

form(txt, mode = "A", type = "dictionary", pos = FALSE)
#> Parsed to 9 tokens
#> Parsed to 6 tokens
#> Parsed to 6 tokens
#> [[1]]
#> [1] "国家"   "公務"   "員"     "は"     "かつ"   "丼"     "を"     "食べる"
#> [9] "たい"  
#> 
#> [[2]]
#> [1] "メロス" "は"     "激怒"   "する"   "た"     "。"    
#> 
#> [[3]]
#> [1] "吾輩" "は"   "猫"   "だ"   "ある" "。"

form("メロスは激怒した", mode = "A", type = "normalized", pos = FALSE)
#> Parsed to 5 tokens
#> [[1]]
#> [1] "メロス" "は"     "激怒"   "為る"   "た"
form("メロスは激怒した", mode = "A", type = "dictionary", pos = FALSE)
#> Parsed to 5 tokens
#> [[1]]
#> [1] "メロス" "は"     "激怒"   "する"   "た"
form("メロスは激怒した", mode = "A", type = "reading", pos = FALSE)
#> Parsed to 5 tokens
#> [[1]]
#> [1] "メロス" "ハ"     "ゲキド" "シ"     "タ"
form("メロスは激怒した", mode = "A", type = "part_of_speech", pos = FALSE)
#> Parsed to 5 tokens
#> [[1]]
#> [[1]][[1]]
#> [1] "名詞"     "普通名詞" "一般"     "*"        "*"        "*"       
#> 
#> [[1]][[2]]
#> [1] "助詞"   "係助詞" "*"      "*"      "*"      "*"     
#> 
#> [[1]][[3]]
#> [1] "名詞"     "普通名詞" "サ変可能" "*"        "*"        "*"       
#> 
#> [[1]][[4]]
#> [1] "動詞"        "非自立可能"  "*"           "*"           "サ行変格"   
#> [6] "連用形-一般"
#> 
#> [[1]][[5]]
#> [1] "助動詞"      "*"           "*"           "*"           "助動詞-タ"  
#> [6] "終止形-一般"
```
