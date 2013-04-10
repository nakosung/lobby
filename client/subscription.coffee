ids = 'userData publicUserData games publicClan board notifications inventory stats'

subscribeEx = (x, others...) ->
  handle = Meteor.subscribe(x,others...)
  Session.set("#{x}-ready",handle?.ready())

interval = null

Meteor.autosubscribe ->
  if interval == null and Meteor.user()?.name
    interval = Meteor.setInterval (-> Meteor.call('keepAlive')), 5000

  return unless Meteor.user()

  _.each(ids.split(' '),(id)->
    subscribeEx id
  )

  u = Session.get('user')
  c = Session.get('clan')
  subscribeEx 'myGame', Meteor.user()?.game
  subscribeEx 'myClan', Meteor.user()?.clan
  subscribeEx 'friends', Meteor.user()?.friends
  subscribeEx 'user-profile', u
  subscribeEx 'clan-profile', c
  subscribeEx 'board', u or c
  subscribeEx 'chats', Meteor.user()?.game
  subscribeEx 'leaderboard' if Session.get('leaderboard')
