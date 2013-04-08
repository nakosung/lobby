Template.game.helpers
  me : ->
    Meteor.user()

  isMaster : (x) ->
    game()?.master == Meteor.userId()

  check : (a,b) ->
    a == b

Template.game.events
  'click .leave' : ->
    Meteor.safeCall 'game.leave'

  'click .ready' : ->
    Meteor.safeCall 'game.ready'

  'click .kickout' : ->
    Meteor.safeCall 'game.kick', @uid,

  'click .edit' : ->
    bootbox.prompt 'New title?', (result) ->
      Meteor.safeCall 'game.edit',
        title : result
