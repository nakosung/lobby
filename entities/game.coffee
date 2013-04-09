grabSomeTitle = ->
  'game room name'

Game.quickMatch = (uid) ->
  game = Games.findOne({full:undefined},{_id:1})

  needToCreate = true
  try
    if game
      Game.join(game._id,uid)
      needToCreate = false
  finally
    Game.create(uid) if needToCreate

Game.edit = (gid,uid,options) ->
  g = Games.findOne(gid)
  throw new Meteor.Error('You are not the master') if g.master != uid

  if options?.title
    Games.update(gid,{$set:{title:options?.title}})

Game.join = (gid,uid) ->
  User.conditionalLeaveGame(uid)

  g = Games.findOne(gid)

  # insert a player if there's room for me
  Games.update {_id:gid,numUsers:{$lt:g.maxCapacity}},
    $push:{users:{uid:uid}}
    $inc:{numUsers:1}

  Games.update {_id:gid,numUsers:g.maxCapacity},
    $set:{full:true}

  # check if succeeded
  if Games.findOne {_id:gid,users:{$elemMatch:{uid:uid}}}
    User.preJoinGame(uid,gid)
  else
    throw new Meteor.Error("couldn't join")

Game.leave = (gid,uid) ->
  g = Games.findOne(gid)
  return g unless g

  Games.update {_id:gid,users:{$elemMatch:{uid:uid}}},
    $pull:{users:{uid:uid}}
    $inc:{numUsers:-1}
    $unset:{full:1}

  # Destroy room if necessary
  Games.remove({_id:gid,users:[]})

  # Hand off master if necessary
  if g.master == uid
    new_master = _.find(_.pluck(g.users,'uid'),((u)->u != uid))
    if not _.isUndefined(new_master)
      Games.update({_id:gid,master:uid},{$set:{master:new_master}})
      User.notify(new_master,"You are the master of this room")

  User.postLeaveGame(uid)

Game.create = (uid,options) ->
  User.conditionalLeaveGame(uid)
  gid = Games.insert
    master:uid
    numUsers:1
    users:[{uid:uid}]
    maxCapacity:16
    createdAt:Date.now()
    title:options?.title or grabSomeTitle()

  User.preJoinGame(uid,gid)
  gid

Game.kick = (gid,uid,target) ->
  g = Games.findOne({_id:gid,master:uid})
  throw new Meteor.Error("No priviledge") unless g
  throw new Meteor.Error("Can't kick yourself") if uid == target

  Game.leave(gid,target)
  User.notify(target,"Kicked out")

Game.readyForGame = (gid,uid) ->
  # erroneous # complain...
  return if @isSimulation

  ready = Games.findOne({_id:gid,users:{$elemMatch:{uid:uid,ready:{$mod:[2,1]}}}}) == undefined
  if ready
    Games.update({_id:gid,users:{$elemMatch:{uid:uid,ready:undefined}}},{$set:{"users.$.ready":1}})
  else
    Games.update({_id:gid,users:{$elemMatch:{uid:uid,ready:1}}},{$unset:{"users.$.ready":1}})

Games.allow
  update : ->
    true

Meteor.methods
  'game.edit' : (options) ->
    gid = Users.findOne(@userId).game
    Game.edit(gid,@userId,options)

  'game.create' : (options) ->
    Game.create(@userId,options)

  'game.join' : (gid) ->
    Game.join(gid,@userId)

  'game.quick' : () ->
    Game.quickMatch(@userId)

  'game.leave' : ->
    User.conditionalLeaveGame(@userId)

  'game.ready' : ->
    gid = Users.findOne(@userId).game
    #Game.readyForGame(gid,@userId) if gid
    Game.readyForGame.call(this,gid,@userId) if gid

  'game.kick' : (uid) ->
    gid = Users.findOne(@userId).game
    Game.kick(gid,@userId,uid)

if Meteor.isServer
  Meteor.startup ->
    Stats.remove({})
    Stats.insert({numGames:0})

    Meteor.setInterval (->
      numGames = Games.find({},{_id:1}).fetch().length
      numUsers = Users.find({heartbeat:{$ne:null}},{_id:1}).fetch().length
      Stats.update({},{$set:{numGames:numGames,numUsers:numUsers}})
    ),1000

