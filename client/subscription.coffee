ids = 'userData publicUserData games chats myClan publicClan board'

_.each(ids.split(' '),(id)->
  Meteor.subscribe id
)

Meteor.autosubscribe ->
  u = Session.get('user')
  c = Session.get('clan')
  Meteor.subscribe 'user-profile', u
  Meteor.subscribe 'clan-profile', c
  Meteor.subscribe 'board', u or c
  Meteor.subscribe 'leaderboard' if Session.get('leaderboard')