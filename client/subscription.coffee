ids = 'userData publicUserData games chats myClan publicClan board'

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

  subscribeEx 'leaderboard' if Session.get('leaderboard')
