Meteor.publish 'userData', ->
  Users.find(@userId,{fields:{game:1,name:1,friends:1,credit:1,online:1,game_lock:1}})

Meteor.publish 'publicUserData', ->
  Users.find({},{fields:{name:1,clan:1,online:1}})

Meteor.publish 'friends', (list) ->
  Users.find({_id:{$in:Users.findOne(@userId)?.friends}},{fields:{game:1,name:1,online:1}})

Meteor.publish 'myGame', (game) ->
  Games.find(game,{})

Meteor.publish 'games', ->
  Games.find({vacancy:{$gt:0}},{limit:3,sort:{numUsers:-1},fields:{numUsers:1,master:1,maxCapacity:1,title:1}})

Meteor.publish 'chats', (context) ->
  Chats.find({context:context},{limit:10,sort:{time:-1}})

Meteor.publish 'clan-profile', (uid) ->
  Clans.find(uid,{})

Meteor.publish 'user-profile', (uid) ->
  Users.find(uid,{})

Meteor.publish 'stats', ->
  Stats.find({})

Meteor.publish 'myClan', (clan) ->
  Clans.find(clan)

Meteor.publish 'publicClan', ->
  Clans.find({},{fields:{name:1}})

Meteor.publish 'board', (bid) ->
  Boards.find(bid,{fields:{articles:1}})

Meteor.publish 'leaderboard', ->
  Users.find({heartbeat:{$ne:undefined}},{fields:{name:1,heartbeat:1},sort:{heartbeat:1},limit:10})

Meteor.publish 'notifications', ->
  Notifications.find({owner:@userId})

Meteor.publish 'inventory', ->
  Items.find({owner:@userId})