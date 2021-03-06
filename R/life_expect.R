#' Calculate life expectancy from a matrix population model
#'
#' Applies Markov chain approaches to obtain mean and variance of life
#' expectancy from a matrix population model (MPM).
#'
#' @param matU The survival component of a MPM (i.e. a square projection matrix
#'   reflecting survival-related transitions; e.g. progression, stasis, and
#'   retrogression).
#' @param start The index of the first stage of the life cycle which the user
#'   considers to be the beginning of life. Defaults to 1. Alternately, a
#'   numeric vector giving the starting population vector (in which case
#'   \code{length(start)} must match \code{ncol(matU))}. See section
#'   \emph{Starting from multiple stages}.
#' 
#' @return Returns life expectancy. If \code{matU} is singular (often indicating
#'   infinite life expectancy), returns \code{NA}.
#'   
#' @author Roberto Salguero-Gomez <rob.salguero@@zoo.ox.ac.uk>
#' @author Hal Caswell <hcaswell@@whoi.edu>
#' 
#' @references Caswell, H. (2001) Matrix Population Models: Construction,
#'   Analysis, and Interpretation. Sinauer Associates; 2nd edition. ISBN:
#'   978-0878930968
#' 
#' @section Starting from multiple stages:
#' Rather than specifying argument \code{start} as a single stage class from
#' which all individuals start life, it may sometimes be desirable to allow for
#' multiple starting stage classes. For example, if the user wants to start their
#' calculation of life expectancy from reproductive maturity (i.e. first
#' reproduction), they should account for the possibility that there may be
#' multiple stage classes in which an individual could first reproduce.
#' 
#' To specify multiple starting stage classes, specify argument \code{start} as
#' the desired starting population vector (\strong{n1}), giving the proportion
#' of individuals starting in each stage class (the length of \code{start}
#' should match the number of columns in the relevant MPM).
#' 
#' See function \code{\link{mature_distrib}} for calculating the proportion of
#' individuals achieving reproductive maturity in each stage class.
#' 
#' @examples
#' data(mpm1)
#' 
#' # life expectancy starting from stage class 2 
#' life_expect(mpm1$matU, start = 2)
#' 
#' # life expectancy starting from first reproduction
#' rep_stages <- repro_stages(mpm1$matF)
#' n1 <- mature_distrib(mpm1$matU, start = 2, repro_stages = rep_stages)
#' life_expect(mpm1$matU, start = n1)
#'
#' @export life_expect
life_expect <- function(matU, start = 1L) {

  # validate arguments
  checkValidMat(matU, warn_surv_issue = TRUE)
  checkValidStartLife(start, matU, start_vec = TRUE)

  # matrix dimension
  matDim <- nrow(matU)
  
  if (length(start) > 1) {
    start_vec <- start / sum(start)
  } else {
    start_vec <- rep(0.0, matDim)
    start_vec[start] <- 1.0
  }
  
  # try calculating fundamental matrix (will fail if matrix singular)
  N <- try(solve(diag(matDim) - matU), silent = TRUE)
  
  if(inherits(N, "try-error")) {
    mean <- NA_real_
    var <- NA_real_
  } else {
  
    Nvar <- try(sum(2*N^2-N)-colSums(N)*colSums(N))
    mean <- sum(colSums(N) * start_vec)
    var <- sum(Nvar * start_vec)
    
  }
  
  
  life_expect <- data.frame("mean" = mean,
                            "var" = var)
  
	return(life_expect)
}

