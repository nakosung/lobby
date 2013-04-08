grabSomeTitle = ->
  'game room name'

Game.edit = (gid,uid,options) ->
  g = Games.findOne(gid)
  throw new Meteor.Error('You are not the master') if g.master != uid

  if options?.title
    Games.update(gid,{$set:{title:options?.title}})

Game.join = (gid,uid) ->
  g = Games.findOne(gid)
  throw new Meteor.Error("no space for new player") if g.users.length >= g.maxCapacity

  return if _.contains(_.pluck(g.users,'uid'),uid)

  User.conditionalLeaveGame(uid)

  User.preJoinGame(uid,gid)

  Games.update({_id:gid},{$addToSet:{users:{uid:uid}}})

Game.leave = (gid,uid) ->
  g = Games.findOne(gid)
  User.postLeaveGame(uid)
  Games.update(gid,{$pull:{users:{uid:uid}}})

  # Destroy room if necessary
  Games.remove({_id:gid,users:[]})

  # Hand off master if necessary
  if g.master == uid
    new_master = _.find(_.pluck(g.users,'uid'),((u)->u != uid))
    Games.update({_id:gid,master:uid},{$set:{master:new_master}})
    User.notify(new_master,"You are the master of this room")

Game.create = (uid) ->
  User.conditionalLeaveGame(uid)
  gid = Games.insert({master:uid,users:[{uid:uid}],maxCapacity:16,createdAt:Date.now(),title:grabSomeTitle()})
  User.preJoinGame(uid,gid)
  gid

Game.kick = (gid,uid,target) ->
  g = Games.findOne({_id:gid,master:uid})
  throw new Meteor.Error("No priviledge") unless g
  throw new Meteor.Error("Can't kick yourself") if uid == target

  Game.leave(gid,target)
  User.notify(target,"Kicked out")

Game.readyForGame = (gid,uid) ->
  ready = Games.findOne({_id:gid,users:{$elemMatch:{uid:uid,ready:{$mod:[2,1]}}}}) == undefined
  if ready
    Games.update({_id:gid,users:{$elemMatch:{uid:uid,ready:undefined}}},{$set:{"users.$.ready":1}})
  else
    Games.update({_id:gid,users:{$elemMatch:{uid:uid,ready:1}}},{$unset:{"users.$.ready":1}})

Games.allow
  update : ->
    true

Meteor.startup ->
  Games.remove({master:undefined})

