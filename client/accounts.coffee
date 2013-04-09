window.game = ->
  Games.findOne(Meteor.user()?.game)

Handlebars.registerHelper 'sessionGet', (x) ->
  Session.get(x)

Template.welcome.events =
  'submit' : (e) ->
    e.preventDefault()
    input = $('.name',$(e.target).parent())
    text = input.val()
    Meteor.safeCall 'changeProfile',
      name:text

Template.lobby.helpers
  games : ->
    Games.find({},{limit:3})

Template.main.helpers
  game : ->
    game()

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
    $('.modal').modal('hide')
    Session.set('user',@_id)

Template.clan_inline.helpers
  clan : ->
    Clans.findOne(String(this))

Template.clan_inline.events
  'click' : ->
    $('.modal').modal('hide')
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
((outer)->
  showingNote = false
  outer.showNotifications = ->
    # guard re-entrance
    return if showingNote

    note = Notifications.findOne({read:undefined})
    if note
      showingNote = true

      endUp = ->
        Notifications.update(note._id,{$set:{read:true}})
        showingNote = false
        Meteor.setTimeout (-> showNotifications()), 1000

      bootbox.alert note.message, ->
        endUp()
)(this)

Notifications.find().observe
  added: ->
    showNotifications()

Template.navbar.helpers
  stats : ->
    Stats.findOne()

Template.navbar.events
  'click #createClan' : ->
    bootbox.prompt 'clan name?', (name) ->
      return unless name

      Meteor.safeCall 'createClan',
        name:name

Template.userHome.helpers
  'user' : ->
    Users.findOne(Session.get('user'))

  'isSelf' : ->
    Meteor.userId() == Session.get('user')

  'isFriend' : ->
    _.contains(Meteor.user()?.friends,Session.get('user'))

Template.userHome.rendered = ->
  $('.modal')
    .modal()
    .on 'hidden', ->
      Session.set('user')

Template.userHome.events
  'click .close' : ->
    $('.modal').modal('hide')

  'click .change' : (e) ->
    bootbox.prompt 'New name?', (result) ->
      if result
        Meteor.safeCall 'changeProfile', {name:result}

  'click .addFriend' : ->
    Meteor.safeCall 'friend.add', @_id

  'click .delFriend' : ->
    Meteor.safeCall 'friend.remove', @_id

Template.clanHome.helpers
  'clan' : ->
    Clans.findOne(Session.get('clan'))

Template.clanHome.rendered = ->
  $('.modal')
    .modal()
    .on 'hidden', ->
      Session.set('clan')

Template.clanHome.events
  'click .close' : ->
      $('.modal').modal('hide')
  'click #joinClan' : ->
    Meteor.safeCall 'joinClan', @_id, (err,result) ->
      if err
        bootbox.alert(err.error)
      else
        bootbox.alert('welcome')

  'click #leaveClan' : ->
    Meteor.call 'leaveClan', (err,result) ->
      if err
        bootbox.alert(err.error)
      else
        $('.modal').modal('hide')
        bootbox.alert('you are freed from the clan')

Template.board.helpers
  'board' : ->
    Boards.findOne(String(this))

Template.board.events
  'submit' : (e) ->
    e.preventDefault()
    input = $('#boardText')
    text = input.val()
    input.val('')
    Meteor.safeCall 'writeBoard', String(this), text

Template.leaderboard.helpers
  'users' : ->
    Users.find({},{sort:{heartbeat:1}})

Template.friends.helpers
  'hasAnyFriend' : ->
    Meteor.user()?.friends?.length > 0

  'friends' : ->
    f = Meteor.user()?.friends
    Users.find({_id:{$in:f}}) if f

Template.inventory.helpers
  'items' : ->
    Items.find({owner:Meteor.userId()})

Template.inventory.events
  'click .dig' : ->
    Meteor.safeCall 'item.dig'
