arraysCanvasXpress <- function() {
  a <- c('colors', 'colorSpectrum', 'shapes', 'sizes', 'patterns', 'images', 'highlightSmp', 'highlightVar', 'smpOverlays', 'varOverlays', 'decorations', 'decorationsColors', 'groupingFactors', 'segregateSamplesBy', 'segregateVariablesBy', 'xAxis', 'xAxisValues', 'xAxisMinorValues', 'timeValues', 'timeValueIndices', 'xAxis2Values', 'xAxis2MinorValues', 'yAxis', 'yAxisValues', 'yAxisMinorValues','zAxis', 'zAxisValues', 'zAxisMinorValues', 'rAxisValues', 'rAxisMinorValues', 'includeDOE', 'vennCompartments', 'vennColors', 'pieColors', 'ringsType', 'ringsWeight', 'stockIndicators', 'highlightNode', 'layoutBoxLabelColors', 'nodesProperties', 'edgesProperties', 'featuresProperties')
}

assertCanvasXpressData <- function(data = NULL, decorData = NULL, smpAnnot = NULL, varAnnot = NULL, nodeData = NULL, edgeData = NULL, vennData = NULL, vennLegend = NULL, genomeData = NULL, graphType = 'Scatter2D') {

	if (graphType == 'Network') {
    if (is.null(nodeData) && is.null(edgeData)) {
		  stop("Missing data for Network visualization!")
    }
	} else if (graphType == 'Venn') {
    if (is.null(vennData)) {
		  stop("Missing data for Venn visualization")
    }
    if (is.null(vennLegend)) {
      stop("Missing legend for Venn visualization")
    }
  } else if (graphType == 'Genome') {
    if (is.null(genomeData)) {
		  stop("Missing data for Genome visualization")
		  stop("Not implemented yet!")
    }
	} else if (is.null(data)) {
		stop("Missing canvasXpress data!")
	}

}

assertCanvasXpressDataFrame <- function(data = NULL, decorData = NULL, smpAnnot = NULL, varAnnot = NULL, nodeData = NULL, edgeData = NULL, vennData = NULL, vennLegend = NULL, genomeData = NULL, graphType = 'Scatter2D') {

	if (graphType == 'Network') {
    if (!is.null(nodeData) && !is.data.frame(nodeData) && !is.matrix(nodeData)) {
      stop("nodeData must be a data frame or a matrix class object.")
      if (!"id" %in% colnames(nodeData)) {
        stop("missing 'id' header in nodeData dataframe.")
      }
    }
    if (!is.null(edgeData) && !is.data.frame(edgeData) && !is.matrix(edgeData)) {
      stop("edgeData must be a data frame or a matrix class object.")
      if (!"id1" %in% colnames(edgeData)) {
        stop("missing 'id1' header in edgeData dataframe.")
      }
      if (!"id2" %in% colnames(edgeData)) {
        stop("missing 'id2' header in edgeData dataframe.")
      }
    }
  } else if (graphType == 'Venn') {
    if (!is.data.frame(vennData) && !is.matrix(vennData)) {
      stop("vennData must be a data frame or a matrix class object.")
    }
    if (length(vennData) == 15) {
      comp = c("A", "B", "C", "D", "AB", "AC", "AD", "BC", "BD", "CD", "ABC", "ABD", "ACD", "BCD", "ABCD")
    } else if (length(vennData) == 7) {
      comp = c("A", "B", "C", "AB", "AC", "BC", "ABC")
    } else {
      comp = c("A", "B", "AB")
    }
    for (c in comp) {
      if (!c %in% colnames(vennData)) {
        stop(cat("missing '", c, "' header in edgeData dataframe.", sep=''))
      }
    }
	} else if (graphType == 'Genome') {
    if (!is.data.frame(genomeData) && !is.matrix(genomeData)) {
      stop("genomeData must be a data frame or a matrix class object.")
    }
	} else {
    if (!is.data.frame(data) && !is.matrix(data)) {
      stop("data must be a data frame or a matrix class object.")
    }
    if (!is.null(smpAnnot) && !is.data.frame(smpAnnot) && !is.matrix(smpAnnot)) {
      stop("smpAnnot must be a data frame or a matrix class object.")
    }
    if (!is.null(varAnnot) && !is.data.frame(varAnnot) && !is.matrix(varAnnot)) {
      stop("varAnnot must be a data frame or a matrix class object.")
    }
  }

}

assignCanvasXpressColnames <- function(x) {
  if (is.null(colnames(x))) {
    paste("V", seq(length = ncol(x)), sep = "")
  } else {
    colnames(x)
  }
}

assignCanvasXpressRownames <- function(x) {
  if (is.null(rownames(x))) {
    paste("V", seq(length = nrow(x)), sep = "")
  } else {
    rownames(x)
  }
}

convertDataFrameCols <- function(df) {
  # From BBmisc
  df = x = as.list(df)
  i = vapply(df, is.factor, TRUE)
  if (any(i)) {
    x[i] = lapply(x[i], as.character)
  }
  as.data.frame(x, stringsAsFactors = FALSE)
}

rowLapply <- function (df, fun, ..., unlist = FALSE) {
  # From BBmisc
  fun = match.fun(fun)
  if (unlist) {
    .wrap = function(.i, .df, .fun, ...) .fun(unlist(.df[.i, , drop = FALSE], recursive = FALSE, use.names = TRUE), ...)
  } else {
    .wrap = function(.i, .df, .fun, ...) .fun(as.list(.df[.i, , drop = FALSE]), ...)
  }
  lapply(seq_row(df), .wrap, .fun = fun, .df = df, ...)
}

seq_row <- function (x) {
  # From BBmisc
  seq_len(nrow(x))
}

convertRowsToList <- function(x) {
  # From BBmisc
  if (is.matrix(x)) {
    res = lapply(seq_row(x), function(i) setNames(x[i,], NULL))
  } else if (is.data.frame(x)) {
    x = convertDataFrameCols(x)
    res = rowLapply(x, function(row) setNames(as.list(row), NULL))
  }
  setNames(res, rownames(x))
}

canvasXpress.data.frame <- function(data = NULL, decorData = NULL, smpAnnot = NULL, varAnnot = NULL, nodeData = NULL, edgeData = NULL, vennData = NULL, vennLegend = NULL, genomeData = NULL, graphType='Scatter2D', events=NULL, afterRender=NULL, width=600, height=400, pretty=FALSE, digits=4, ...) {
  canvasXpress(data, decorData, smpAnnot, varAnnot, nodeData, edgeData, vennData, vennLegend, genomeData, graphType, events, afterRender, width, height, pretty, digits, ...)
}

canvasXpress <- function(data = NULL, decorData = NULL, smpAnnot = NULL, varAnnot = NULL, nodeData = NULL, edgeData = NULL, vennData = NULL, vennLegend = NULL, genomeData = NULL, graphType='Scatter2D', events=NULL, afterRender=NULL, width=600, height=400, pretty=FALSE, digits=4, ...) {

  assertCanvasXpressData(data, decorData, smpAnnot, varAnnot, nodeData, edgeData, vennData, vennLegend, genomeData, graphType)
  assertCanvasXpressDataFrame(data, decorData, smpAnnot, varAnnot, nodeData, edgeData, vennData, vennLegend, genomeData, graphType)
  dataframe = "columns"

  # Data
  if (graphType == 'Network') {
    nodes <- NULL
    edges <- NULL
    if (!is.null(nodeData)) {
      nodes <- nodeData
    }
    if (!is.null(edgeData)) {
      edges <- edgeData
      if (is.null(nodeData)) {
        nodes <- unique(c(as.vector(edgeData[,grep("id1", colnames(edgeData))]), as.vector(edgeData[,grep("id2", colnames(edgeData))])))
        names(nodes) <- rep("id", length(nodes))
      }
    }
    dataframe = "rows"
    data <- list(nodes = nodes, edges = edges)
  } else if (graphType == 'Venn') {
    dataframe = "columns"
    data <- list(venn = list(data = vennData, legend = vennLegend))
  } else if (graphType == 'Genome') {
  } else {
    vars = as.list(assignCanvasXpressRownames(data))
    smps = as.list(assignCanvasXpressColnames(data))
    dy <- as.matrix(data)
    dimnames(dy) <- NULL
    y <- list(vars = vars, smps = smps, data = dy)
    x <- NULL
    z <- NULL
    if (!is.null(smpAnnot)) {
      vars2 = as.list(assignCanvasXpressRownames(smpAnnot))
      smps2 = as.list(assignCanvasXpressColnames(smpAnnot))
      if (!identical(vars2, smps)) {
        smpAnnot <- t(smpAnnot)
        vars2 = as.list(assignCanvasXpressRownames(smpAnnot))
        smps2 = as.list(assignCanvasXpressColnames(smpAnnot))
      }
      if (!identical(vars2, smps)) {
	      stop("Column names in smpAnnot are different from column names in data")
      }
      x <- lapply(convertRowsToList(t(smpAnnot)), function (d) if (length(d) > 1) d else list(d))
    }
    if (!is.null(varAnnot)) {
      vars3 = as.list(assignCanvasXpressRownames(varAnnot))
      smps3 = as.list(assignCanvasXpressColnames(varAnnot))
      if (!identical(vars3, vars)) {
	      stop("Row names in varAnnot are different from row names in data")
      }
      z <- lapply(convertRowsToList(t(varAnnot)), function (d) if (length(d) > 1) d else list(d))
    }
    if (!is.null(decorData)) {
      data <- list(y = y, x = x, z = z, d = decorData)
    } else {
      data <- list(y = y, x = x, z = z)
    }
  }

  # Config
  config <- list(graphType = graphType, isR = TRUE, ...)

  # Events
  # Nothing to do

  # After Render
  # Nothing to do

  # CanvasXpress Object
  cx = list(data = data, config = config, events = events, afterRender = afterRender)

  ## toJSON option
  options(htmlwidgets.TOJSON_ARGS = list(dataframe = dataframe, pretty = pretty, digits = digits))

  # Create the widget
  htmlwidgets::createWidget("canvasXpress", cx, width = width, height = height)

}

canvasXpressOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "canvasXpress", width, height, package = "canvasXpress")
}

renderCanvasXpress <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, canvasXpressOutput, env, quoted = TRUE)
}
