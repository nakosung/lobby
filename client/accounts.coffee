game = ->
  Games.findOne(Meteor.user()?.game)

root.game = game

Handlebars.registerHelper 'sessionGet', (x) ->
  Session.get(x)

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
    Meteor.call 'game.create', (err) ->
      bootbox.alert err.error if err

Template.game_item.events
  'click .join' : ->
    Meteor.call 'game.join', @_id, (err) ->
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

Template.profile_inline.helpers
  user : ->
    Users.findOne(String(this))

Template.profile_inline.events
  'click' : ->
    Session.set('clan',undefined)
    Session.set('user',@_id)

Template.clan_inline.helpers
  clan : ->
    Clans.findOne(String(this))

Template.clan_inline.events
  'click' : ->
    Session.set('user',undefined)
    Session.set('clan',@_id)

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

Handlebars.registerHelper 'eq', (x,y) ->
  x == y

Handlebars.registerHelper 'neq', (x,y) ->
  x != y

## Bring notifications on screen!
Users.find().observe
  changed: ->
    if Meteor.user()?.notifications?.length
      Meteor.call 'popNotification', (err,result) ->
        bootbox.alert(result)

Template.navbar.events
  'click #createClan' : ->
    bootbox.prompt 'clan name?', (name) ->
      return unless name

      options =
        name:name
      Meteor.call 'createClan', options, (err,result) ->
        if err
          bootbox.alert err.error
        else
          Session.set 'clan', result

Template.userHome.helpers
  'user' : ->
    Users.findOne(Session.get('user'))

Template.userHome.events
  'click .change' : (e) ->
    bootbox.prompt 'New name?', (result) ->
      if result
        Meteor.call 'changeProfile', {name:result}, (err,result) ->
          bootbox.alert err.error if err

Template.clanHome.helpers
  'clan' : ->
    Clans.findOne(Session.get('clan'))

Template.clanHome.events
  'click #joinClan' : ->
    Meteor.call 'joinClan', @_id, (err,result) ->
      if err
        bootbox.alert(err.error)
      else
        bootbox.alert('welcome')

  'click #leaveClan' : ->
    Meteor.call 'leaveClan', (err,result) ->
      if err
        bootbox.alert(err.error)
      else
        bootbox.alert('you are freed from the clan')
        Session.set('clan')

Template.board.helpers
  'board' : ->
    Boards.findOne(String(this))

Template.board.events
  'submit' : (e) ->
    e.preventDefault()
    input = $('#boardText')
    Meteor.call 'writeBoard', String(this), input.val(), (err,result) ->
      input.val('')
      bootbox.alert err.error if err

Template.leaderboard.helpers
  'users' : ->
    Users.find({},{sort:{heartbeat:1}})

TestRouter = Backbone.Router.extend
  routes:
    '' : 'main'
    'Leaderboard' : 'leaderboard'
  main:(url_path) ->
    Session.set('user')
    Session.set('clan')
  leaderboard:(url_path) ->
    Session.set('leaderboard',1)
    Session.set('user')
    Session.set('clan')

Router = new TestRouter
Meteor.startup ->
  Backbone.history.start({pushState:true})