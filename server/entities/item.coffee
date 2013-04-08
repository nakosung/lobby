Meteor.methods
  'item.dig' : ->
    Items.insert({owner:@userId,description:'valuable thing',expireAt:Date.now() + 1000*6})

Meteor.autorun ->
  Items.update({expireAt:undefined},{expireAt:0},false,true)
  f = ->
    Items.remove({expireAt:{$lt:Date.now()}})
  Meteor.setInterval f, 5000