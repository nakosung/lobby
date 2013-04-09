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

User.keepAlive = (uid) ->
  Users.update(uid,{$set:{heartbeat:Date.now(),online:true}})

Meteor.methods
  'changeProfile' : (options) ->
    name = options?.name
    if name
      throw new Meteor.Error('invalid name') unless name.length > 2
      throw new Meteor.Error('name in use') if Users.findOne({name:name},{_id:1})
      Users.update(@userId,{$set:{name:name}})
      Users._ensureIndex({name:1},{unique:true})

  'keepAlive' : ->
    User.keepAlive(@userId)

  'friend.add' : (uid) ->
    throw new Meteor.Error('self cannot be a friend') if @userId == uid

    Users.update(@userId,{$addToSet:{friends:uid}})

  'friend.remove' : (uid) ->
    throw new Meteor.Error('self cannot be a friend') if @userId == uid

    Users.update(@userId,{$pull:{friends:uid}})


## Connection lost handler
cleanUp = ->
  cursor = Users.find({heartbeat:{$lt:Date.now()-30000}},{_id:1})
  uids = _.pluck cursor.fetch(),'_id'
  _.each uids, User.logoff

Meteor.setInterval cleanUp, 15 * 1000

if Meteor.isServer
  Meteor.startup ->
    Users.update({credit:undefined},{$set:credit:0})