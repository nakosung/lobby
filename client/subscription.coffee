ids = 'userData publicUserData games myClan publicClan board notifications'

subscribeEx = (x, others...) ->
  handle = Meteor.subscribe(x,others...)
  Session.set("#{x}-ready",handle?.ready())

Meteor.autosubscribe ->
  _.each(ids.split(' '),(id)->
    subscribeEx id
  )

  u = Session.get('user')
  c = Session.get('clan')
  subscribeEx 'user-profile', u
  subscribeEx 'clan-profile', c
  subscribeEx 'board', u or c
  subscribeEx 'chats', Meteor.user()?.game
  subscribeEx 'leaderboard' if Session.get('leaderboard')
