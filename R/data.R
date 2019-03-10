#' Distinct words in Cervantes' "Don Quijote".
#'
#' Dataframe listing all distinct words (length>3), their length,
#' and frequency of appearance in text.
#'
#' @format A data frame w/ ~22k rows and 3 cols:
#' \describe{
#'   \item{word}{the unique word, in Spanish}
#'   \item{len}{the word's length}
#'   \item{freq}{number of appearances in text}
#' }
#' @source \url{http://www.gutenberg.org/cache/epub/2000/pg2000.txt}
"quijote_words"
