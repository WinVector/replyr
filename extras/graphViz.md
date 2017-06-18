How to render a [`replyr`](https://github.com/WinVector/replyr) join diagram directly into R Markdown (source code [here](https://github.com/WinVector/replyr/blob/master/extras/graphViz.Rmd), [view raw](https://raw.githubusercontent.com/WinVector/replyr/master/extras/graphViz.Rmd)).

Please see [here](http://www.win-vector.com/blog/2017/06/use-a-join-controller-to-document-your-work/) for a discussion and motiviation of `replyr` join diagrams.

Converter info from: [here](https://stackoverflow.com/questions/31336898/how-to-save-leaflet-in-r-map-as-png-or-jpg-file).

``` r
library("replyr")
library("htmlwidgets")
library("webshot")
# instructions: https://github.com/wch/webshot/ 
# webshot::install_phantomjs()
library("magick")
# install instructions: https://github.com/ropensci/magick#readme

tDesc <- data.frame(tableName= c('employeeAndDate',
                                 'orgtable',
                                 'revenue',
                                 'activity'),
                    handle= I(list(NULL, NULL, NULL, NULL)),
                    columns= I(list(c('id', 'date'),
                                    c('id', 'date', 'dept'),
                                    c('date', 'dept', 'rev'),
                                    c('id', 'date', 'hours'))),
                    keys =  I(list( c('id', 'date'),
                                   c('id', 'date'),
                                   c('date', 'dept'),
                                   c('id', 'date'))),
                    colClass= I(list(c('character', 'numeric'),
                                     c('character', 'character', 'character'),
                                     c('numeric', 'character', 'numeric'),
                                     c('character', 'numeric', 'numeric'))),
                    sourceClass= 'None',
                    isEmpty= FALSE,
                    stringsAsFactors = FALSE)
diagramSpec <- makeJoinDiagramSpec(buildJoinPlan(tDesc))
diagram <- DiagrammeR::grViz(diagramSpec)


# render as HTML and then get an PNG webshot.
# returns path to the temp directory it used for intermediate results (user may want to remove it later).
saveDiagramAsPNG <- function(diagram, fileName) {
  dir <- tempdir()
  tempPath <- paste(dir, 'temp.html', sep= '/')
  saveWidget(diagram, tempPath, selfcontained = FALSE)
  webshot(tempPath, file = fileName,
          cliprect = "viewport")
  img <- image_read(fileName)
  img <- image_trim(img)
  image_write(img, path = fileName, format = "png")
  # intentionally not removing the temp directory, as it could be dangerous
  # Command would be: unlink(dir, recursive = TRUE)
  dir
}

pngName <- 'joinPlan.png'
tmpdir <- saveDiagramAsPNG(diagram, pngName)
```

<img src="joinPlan.png" width="600">
