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

  'click .edit' : ->
    bootbox.prompt 'New title?', (result) ->
      options =
        title : result
      Meteor.call 'game.edit', options, (err,result) ->
        bootbox.alert err.error if err
