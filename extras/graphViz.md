How to render a [`replyr`](https://github.com/WinVector/replyr) join diagram directly into R Markdown (source code [here](https://github.com/WinVector/replyr/blob/master/extras/graphViz.Rmd), [view raw](https://raw.githubusercontent.com/WinVector/replyr/master/extras/graphViz.Rmd)).

Please see [here](http://www.win-vector.com/blog/2017/06/use-a-join-controller-to-document-your-work/) for a discussion and motiviation of `replyr` join diagrams.

Converter info from: [here](https://stackoverflow.com/questions/31336898/how-to-save-leaflet-in-r-map-as-png-or-jpg-file).

``` r
library("replyr")

# example from help('makeJoinDiagramSpec', package= 'replyr')

# note: employeeAndDate is likely built as a cross-product
#       join of an employee table and set of dates of interest
#       before getting to the join controller step.  We call
#       such a table "row control" or "experimental design."
# Normally tDesc is produced by inspecting tables using 
# replyr::tableDescription() and then limiting the keys
# column down to the correct specification.
# For this example we just type tDesc in directly.
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
pngFileName <- 'joinPlan.png'
diagramPNG <- renderJoinDiagram(diagramSpec, 
                                pngFileName = pngFileName)
```

<center>
<img src="joinPlan.png" width="600" border="0">
</center>
