ic_join_bands<- function(x, y, by){

  # Define an inner join
  innerJoin = rgee::ee$Join$inner()

  # Specify an equals filter for image timestamps.
  filterEq <- rge::ee$Filter$equals(leftField = by, rightField = by)

  # Apply the join.
  innerJoined_ic = innerJoin$apply(ic1, ic2, filterEq)


  # Map a function to merge the results in the output FeatureCollection.
  # in the JavaScript code-editor this seems to auto-convert/get coerced to ImageCollection
  joined_fc = innerJoined_ic$map(function(feature)  {
    ee$Image$cat(feature$get('primary'), feature$get('secondary'))
  })

  # with rgee is seems necessary to explicitly convert
  rge::ee$ImageCollection(joined_fc)
}
