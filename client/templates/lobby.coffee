Template.welcome.events =
  'submit' : (e) ->
    e.preventDefault()
    input = $('.name',$(e.target).parent())
    text = input.val()
    Meteor.safeCall 'changeProfile',
      name:text

Template.lobby.helpers
  games : ->
    Games.find({},{limit:3,sort:{numUsers:-1}})

Template.lobby.events
  'click .quick' : ->
    Meteor.safeCall 'game.quick'

  'click .create' : ->
    bootbox.prompt 'Title?', (result) ->
      if result
        Meteor.safeCall 'game.create',
          title:result

Template.game_item.events
  'click .join' : ->
    Meteor.safeCall 'game.join', @_id
