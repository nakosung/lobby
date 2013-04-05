Template.game.helpers
  me : ->
    Meteor.user()

  isMaster : (x) ->
    game().master == Meteor.userId()

  check : (a,b) ->
    a == b

Template.game.events
  'click .leave' : ->
    Meteor.call 'leaveGame'

  'click .ready' : ->
    Meteor.call 'readyForGame'

  'click .kickout' : ->
    Meteor.call 'kickUser', @uid, (err) ->
      bootbox.alert if err then err.error else 'Okay!'
