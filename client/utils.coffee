Meteor.safeCall = (x,y...) ->
  Meteor.call x,y...,(err,result) ->
    if err
      bootbox.alert err.error
