window.game = ->
  Games.findOne(Meteor.user()?.game)

Template.main.helpers
  game : ->
    game()

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
