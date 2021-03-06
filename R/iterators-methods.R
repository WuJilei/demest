
## Strictly speaking these aren't methods. We use the suffixes A, B, C, and D
## to show what class of iterator the functions are applied to, rather than
## formal method dispatch, since the functions are used in C.

## AlongIterators ###########################################################

## TRANSLATED
## HAS_TESTS
advanceA <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "AlongIterator"))
    methods::validObject(object)
    if (useC) {
        .Call(advanceA_R, object)
    }
    else {
        if (object@iWithin < object@nWithin) {
            object@iWithin <- object@iWithin + 1L
            object@indices <- object@indices + 1L
        }
        else {
            object@iWithin <- 1L
            if (object@iBetween < object@nBetween) {
                object@iBetween <- object@iBetween + 1L
                object@indices <- object@indices + object@incrementBetween
            }
            else {
                object@iBetween <- 1L
                object@indices <- object@initial
            }
        }
        object
    }
}

## TRANSLATED
## HAS_TESTS
resetA <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "AlongIterator"))
    methods::validObject(object)
    if (useC) {
        .Call(resetA_R, object)
    }
    else{
        object@iWithin <- 1L
        object@iBetween <- 1L
        object@indices <- object@initial
        object
    }
}


## BetaIterators ###########################################################

## TRANSLATED
## HAS_TESTS
advanceB <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "BetaIterator"))
    stopifnot(methods::validObject(object))
    if (useC) {
        .Call(advanceB_R, object)
    }
    else {
        indices <- object@indices
        dim.iterators <- object@dimIterators
        stride.lengths <- object@strideLengths
        n.beta <- length(indices)
        if (n.beta > 1L) { ## more than just intercept term
            for (d in seq_along(dim.iterators))
                dim.iterators[[d]] <- advanceD(dim.iterators[[d]])
            for (b in seq.int(from = 2L, to = n.beta)) {
                for (d in seq_along(dim.iterators)) {
                    n.strides <- dim.iterators[[d]]@nStrides
                    stride.length <- stride.lengths[[b - 1L]][d]
                    indices[[b]] <- indices[[b]] + as.integer(n.strides * stride.length)
                }
            }
            object@indices <- indices
            object@dimIterators <- dim.iterators
        }
        object
    }
}

## TRANSLATED
## HAS_TESTS
resetB <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "BetaIterator"))
    stopifnot(methods::validObject(object))
    if (useC) {
        .Call(resetB_R, object)
    }
    else {
        n.beta <- length(object@indices)
        if (n.beta > 1L) { ## more than just intercept term
            for (b in seq.int(from = 2L, to = n.beta))
                object@indices[b] <- 1L
            for (d in seq_along(object@dimIterators))
                object@dimIterators[[d]] <- resetD(object@dimIterators[[d]])
        }
        object
    }
}


## CohortIterators ###########################################################


## TRANSLATED
## HAS_TESTS
## It is the caller's responsibility to make
## sure that the iterator has not finished
advanceCAP <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "CohortIteratorAccessionPopulation"))
    if (useC) {
        .Call(advanceCAP_R, object) ## NAME CHANGED
    }
    else {
        i <- object@i
        step.time <- object@stepTime
        n.time <- object@nTime
        i.time <- object@iTime
        has.age <- object@hasAge
        i.time <- i.time + 1L
        i <- i + step.time
        if (has.age) {
            step.age <- object@stepAge
            n.age <- object@nAge
            i.age <- object@iAge
            if (i.age < n.age) {
                i.age <- i.age + 1L
                i <- i + step.age
            }
        }
        finished <- i.time == n.time
        object@i <- i
        object@iTime <- i.time
        if (has.age)
            object@iAge <- i.age
        object@finished <- finished
        object
    }
}

## TRANSLATED
## HAS_TESTS
## It is the caller's responsibility to make
## sure that the iterator has not finished
advanceCC <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "CohortIteratorComponent"))
    if (useC) {
        .Call(advanceCC_R, object)
    }
    else {
        i <- object@i
        step.time <- object@stepTime
        n.time <- object@nTime
        i.time <- object@iTime
        has.age <- object@hasAge
        if (has.age) {
            step.age <- object@stepAge
            n.age <- object@nAge
            i.age <- object@iAge
            step.triangle <- object@stepTriangle
            i.triangle <- object@iTriangle
            if (i.triangle == 1L) {
                i.time <- i.time + 1L
                i.triangle <- 2L
                i <- i + step.time + step.triangle
            }
            else {
                if (i.age < n.age) {
                    i.age <- i.age + 1L
                    i.triangle <- 1L
                    i <- i + step.age - step.triangle
                }
                else {
                    i.time <- i.time + 1L
                    i <- i + step.time
                }
            }
            finished <- (i.triangle == 1L) && (i.time == n.time)
        }
        else {
            i.time <- i.time + 1L
            i <- i + step.time
            finished <- i.time == n.time
        }
        object@i <- i
        object@iTime <- i.time
        if (has.age) {
            object@iAge <- i.age
            object@iTriangle <- i.triangle
        }
        object@finished <- finished
        object
    }
}

## ## NO_TESTS
## ## It is the caller's responsibility to make
## ## sure that the iterator has not finished
## advanceCODPCP <- function(object, useC = FALSE) {
##     stopifnot(methods::is(object, "CohortIteratorOrigDestParChPool"))
##     if (useC) {
##         .Call(advanceCODPCP_R, object)
##     }
##     else {
##         object <- advanceCC(object)
##         i <- object@i
##         i.vec <- object@iVec
##         length <- object@lengthVec
##         increments <- object@increments
##         for (j in seq_len(lengthVec))
##             i.vec[j] <- i + increments[j]
##         object@iVec <- i.vec
##         object
##     }
## }

## TRANSLATED
## HAS_TESTS
resetCAP <- function(object, i, useC = FALSE) {
    ## 'object'
    stopifnot(methods::is(object, "CohortIteratorAccessionPopulation"))
    ## 'i'
    stopifnot(is.integer(i))
    stopifnot(identical(length(i), 1L))
    stopifnot(!is.na(i))
    stopifnot(i >= 1L)
    if (useC) {
        .Call(resetCAP_R, object, i)  ## NAME CHANGED
    }
    else {
        step.time <- object@stepTime
        n.time <- object@nTime
        has.age <- object@hasAge
        i.time <- (((i - 1L) %/% step.time) %% n.time) + 1L # R-style
        if (has.age) {
            step.age <- object@stepAge
            n.age <- object@nAge
            i.age <- (((i - 1L) %/% step.age) %% n.age) + 1L # R-style
        }
        finished <- i.time >= n.time
        object@i <- i
        object@iTime <- i.time
        if (has.age)
            object@iAge <- i.age
        object@finished <- finished
        object
    }
}

## TRANSLATED
## HAS_TESTS
resetCC <- function(object, i, useC = FALSE) {
    ## 'object'
    stopifnot(methods::is(object, "CohortIteratorComponent"))
    ## 'i'
    stopifnot(is.integer(i))
    stopifnot(identical(length(i), 1L))
    stopifnot(!is.na(i))
    stopifnot(i >= 1L)
    if (useC) {
        .Call(resetCC_R, object, i)
    }
    else {
        step.time <- object@stepTime
        n.time <- object@nTime
        has.age <- object@hasAge
        i.time <- (((i - 1L) %/% step.time) %% n.time) + 1L # R-style
        if (has.age) {
            step.age <- object@stepAge
            n.age <- object@nAge
            i.age <- (((i - 1L) %/% step.age) %% n.age) + 1L # R-style
            step.triangle <- object@stepTriangle
            i.triangle <- (((i - 1L) %/% step.triangle) %% 2L) + 1L # R-style
        }
        finished <- i.time >= n.time
        object@i <- i
        object@iTime <- i.time
        if (has.age) {
            object@iAge <- i.age
            object@iTriangle <- i.triangle
        }
        object@finished <- finished
        object
    }
}

## TRANSLATED
resetCODPCP <- function(object, i, useC = FALSE) {
    ## 'object'
    stopifnot(methods::is(object, "CohortIteratorOrigDestParChPool"))
    ## 'i'
    stopifnot(is.integer(i))
    stopifnot(identical(length(i), 1L))
    stopifnot(!is.na(i))
    stopifnot(i >= 1L)
    if (useC) {
        .Call(resetCODPCP_R, object, i)
    }
    else {
        object <- resetCC(object = object, i = i)
        i <- object@i
        i.vec <- object@iVec
        increment <- object@increment
        length <- object@lengthVec
        for (j in seq_len(length))
            i.vec[j] <- i + increment[j]
        object@iVec <- i.vec
        object
    }
}        



## DimIterators ###########################################################

## TRANSLATED
## HAS_TESTS
advanceD <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "DimIterator"))
    stopifnot(methods::validObject(object))
    if (useC) {
        .Call(advanceD_R, object)
    }
    else {
        if (object@iWithin < object@nWithin) {
            object@iWithin <- object@iWithin + 1L
            object@nStrides <- 0L
        }
        else {
            object@iWithin <- 1L
            if (object@iBetween < object@nBetween) {
                object@iBetween <- object@iBetween + 1L
                object@nStrides <- 1L
            }
            else {
                object@iBetween <- 1L
                object@nStrides <- 1L - object@nBetween
            }
        }
        object
    }
}

## TRANSLATED
## HAS_TESTS
resetD <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "DimIterator"))
    stopifnot(methods::validObject(object))
    if (useC) {
        .Call(resetD_R, object)
    }
    else {
        object@nStrides <- 1L - object@nBetween
        object@iWithin <- 1L
        object@iBetween <- 1L
        object
    }
}


## Margin Iterator ####################################################################

## TRANSLATED
## HAS_TESTS
advanceM <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "MarginIterator"))
    stopifnot(methods::validObject(object))
    if (useC) {
        .Call(advanceM_R, object)
    }
    else {
        for (i in seq_along(object@indices)) {
            object@dimIterators[[i]] <- advanceD(object@dimIterators[[i]])
            object@indices[[i]] <- object@dimIterators[[i]]@iBetween
        }
        object
    }
}

## TRANSLATED
## HAS_TESTS
resetM <- function(object, useC = FALSE) {
    stopifnot(methods::is(object, "MarginIterator"))
    stopifnot(methods::validObject(object))
    if (useC) {
        .Call(resetM_R, object)
    }
    else {
        for (i in seq_along(object@indices)) {
            object@indices[[i]] <- 1L
            object@dimIterators[[i]] <- resetD(object@dimIterators[[i]])
        }
        object
    }
}


## PosInTarget Iterator ##########################################################

## ## TRANSLATED
## ## HAS_TESTS
## advancePT <- function(object, useC = FALSE) {
##     stopifnot(methods::is(object, "PosInTargetIterator"))
##     stopifnot(methods::validObject(object))
##     if (useC) {
##         .Call(advancePT_R, object)
##     }
##     else {
##         indices <- object@indices
##         dims <- object@dims
##         dim.iterators <- object@dimIterators
##         multipliers <- object@multipliers
##         pos <- 1L
##         in.after <- TRUE
##         for (i.dim.before in seq_along(indices)) {
##             dim.iterators[[i.dim.before]] <- advanceD(dim.iterators[[i.dim.before]])
##             if (in.after) {
##                 i.between.before <- dim.iterators[[i.dim.before]]@iBetween
##                 i.between.after <- indices[[i.dim.before]][i.between.before]
##                 in.after <- i.between.after > 0L
##                 if (in.after) {
##                     i.dim.after <- dims[i.dim.before]
##                     collapsed <- i.dim.after == 0L
##                     if (!collapsed)
##                         pos <- pos + multipliers[i.dim.after] * (i.between.after - 1L)
##                 }
##                 else
##                     pos <- 0L
##             }
##         }
##         object@pos <- pos
##         object@dimIterators <- dim.iterators
##         object
##     }
## }
