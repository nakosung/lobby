Meteor.publish 'userData', ->
  Users.find(@userId,{fields:{game:1,name:1}})

Meteor.publish 'publicUserData', ->
  Users.find({},{fields:{name:1,clan:1}})

Meteor.publish 'games', ->
  Games.find({users:{$ne:[]}})

Meteor.publish 'chats', ->
  Chats.find({})

Meteor.publish 'clan-profile', (uid) ->
  Clans.find(uid,{})

Meteor.publish 'user-profile', (uid) ->
  Users.find(uid,{})

Meteor.publish 'myClan', ->
  Clans.find(Users.findOne(@userId)?.clan)

Meteor.publish 'publicClan', ->
  Clans.find({},{fields:{name:1}})

Meteor.publish 'board', (bid) ->
  Boards.find(bid,{fields:{articles:1}})

Meteor.publish 'leaderboard', ->
  Users.find({},{fields:{name:1,heartbeat:1}})