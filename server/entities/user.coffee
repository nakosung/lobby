User.preJoinGame = (uid,gid) ->
  Users.update(uid,{$set:{game:gid}})

User.postLeaveGame = (uid) ->
  Users.update(uid,{$unset:{game:1}})

User.conditionalLeaveGame = (uid) ->
  u = Users.findOne(uid)
  Game.leave(u.game,uid) if u.game

User.notify = (uid,msg) ->
  Notifications.insert({owner:uid,message:msg})

User.logoff = (uid) ->
  User.conditionalLeaveGame(uid)
  Users.update(uid,{$unset:{heartbeat:1},$set:{online:true}})

## Connection lost handler
cleanUp = ->
  cursor = Users.find({heartbeat:{$lt:Date.now()-30000}},{_id:1})
  uids = _.pluck cursor.fetch(),'_id'
  _.each uids, User.logoff

Meteor.setInterval cleanUp, 15 * 1000

Meteor.startup ->
  Users.update({credit:undefined},{$set:credit:0})