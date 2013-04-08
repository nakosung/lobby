Template.game.helpers
  me : ->
    Meteor.user()

  isMaster : (x) ->
    game()?.master == Meteor.userId()

  check : (a,b) ->
    a == b

Template.game.events
  'click .leave' : ->
    Meteor.call 'game.leave'

  'click .ready' : ->
    Meteor.call 'game.ready'

  'click .kickout' : ->
    Meteor.call 'game.kick', @uid, (err) ->
      bootbox.alert if err then err.error else 'Okay!'
