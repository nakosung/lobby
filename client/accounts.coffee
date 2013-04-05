game = ->
  Games.findOne(Meteor.user()?.game)

root.game = game

Template.welcome.events =
  'submit' : (e) ->
    e.preventDefault()
    input = $('.name',$(e.target).parent())
    text = input.val()
    Meteor.call 'changeProfile', {name:text}, (err,result) ->
      input.val(Meteor.user().name)

Template.lobby.helpers
  games : ->
    Games.find()

Template.main.helpers
  game : ->
    game()

Template.lobby.events
  'click .create' : ->
    Meteor.call 'createGame', (err) ->
      bootbox.alert err.error if err

Template.game_item.events
  'click .join' : ->
    Meteor.call 'joinGame', @_id, (err) ->
      bootbox.alert err.error if err

Template.chat.helpers
  chats : ->
    Chats.find()

Template.chat.events
  'submit' : (e) ->
    e.preventDefault()
    input = $('.input',$(e.target).parent())
    text = input.val()
    input.val('')

    Meteor.call 'chat',text if text != ""

Template.chat.rendered = ->
  chat = $(@find('.chatWindow'))
  chat.scrollTop chat.get(0).scrollHeight

Template.profile.events
  'submit' : (e) ->
    e.preventDefault()
    input = $('.name',$(e.target).parent())
    text = input.val()

    Meteor.call 'changeProfile', {name:text}, (err,result) ->
      input.val(Meteor.user().name)

Template.profile_inline.helpers
  name : ->
    Users.findOne(String(this))?.name

interval = null
Meteor.autosubscribe ->
  Meteor.subscribe 'profile', Session.get('profileTarget')
  if interval == null and Meteor.user()?.name
    interval = Meteor.setInterval (-> Meteor.call('keepAlive')), 5000

Template.profile_inline.events
  'click a' : ->
    Session.set('profileTarget',String(this))

Handlebars.registerHelper 'not', (x) ->
  not x

Handlebars.registerHelper 'moment', (x) ->
  moment x

## Bring notifications on screen!
Users.find().observe
  changed: ->
    if Meteor.user()?.notifications?.length
      Meteor.call 'popNotification', (err,result) ->
        bootbox.alert(result)

