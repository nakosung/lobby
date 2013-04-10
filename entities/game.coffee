grabSomeTitle = ->
  'game room name'

Game.quickMatch = (uid) ->
  game = Games.findOne({vacancy:{$gt:0}},{_id:1})

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

  editor =
    title : (target) ->
      Games.update(gid,{$set:{title:options?.title}})

    maxCapacity : (target) ->
      diff = target - g.maxCapacity
      requiredVacancy = if diff < 0 then -diff else 0
      Games.update {_id:gid,maxCapacity:g.maxCapacity,vacancy:{$gt:requiredVacancy}},
        $inc:{maxCapacity:diff,vacancy:diff}
      throw new Meteor.Error('failed to modify maxCapacity') unless Games.findOne {_id:gid,maxCapacity:target}

  _.each options, (v,k) ->
    e = editor[k]
    throw new Meteor.Error("invalid field: #{k}") unless e
    e(v)

Game.join = (gid,uid) ->
  User.conditionalLeaveGame(uid)

  try
    commit [markPendingGame,pendJoin,join,setGame],
      gid:gid
      uid:uid
  catch e
    Game.conditionalDestroy(gid)
    throw e

Game.conditionalDestroy = (gid) ->
  Games.remove({_id:gid,users:[],pendingJoin:[]})

Game.leave = (gid,uid) ->
  commit [markPendingGame,markFullIfSolo,conditionalHandOffMaster,unsetGame,removeFromGame],
    gid:gid
    uid:uid

  Game.conditionalDestroy(gid)

Game.create = (uid,options) ->
  User.conditionalLeaveGame(uid)

  gid = Meteor.uuid()

  options = options or {}
  options.maxCapacity ?= 16
  options.title ?= grabSomeTitle()

  commit [markPendingGame,create,setGame],
    gid:gid
    uid:uid
    options:options

  gid

Game.kick = (gid,uid,target) ->
  throw new Meteor.Error("Can't kick yourself") if uid == target

  commit [markPendingGame,unsetGame,removeFromGame],
    gid:gid
    uid:target

  User.notify(target,"Kicked out")

Game.readyForGame = (gid,uid) ->
  ready = Games.findOne({_id:gid,users:{$elemMatch:{uid:uid,ready:{$mod:[2,1]}}}}) == undefined
  if @isSimulation
    # cannot update :(
  else
    if ready
      Games.update({_id:gid,users:{$elemMatch:{uid:uid,ready:undefined}}},{$set:{"users.$.ready":1}})
    else
      Games.update({_id:gid,users:{$elemMatch:{uid:uid,ready:1}}},{$unset:{"users.$.ready":1}})


if Meteor.isServer
  Meteor.methods
    'game.quick' : () ->
      Game.quickMatch.call(this,@userId)

Meteor.methods
  'game.edit' : (options) ->
    gid = Users.findOne(@userId).game
    Game.edit(gid,@userId,options)

  'game.create' : (options) ->
    Game.create(@userId,options)

  'game.join' : (gid) ->
    if @isSimulation
      Users.update(@userId,{$set:{game:gid}})
    else
      Game.join(gid,@userId)

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
    Games.update({},{$unset:{pendingJoin:1}},{multi:true})
    Users.update({},{$unset:{game:1,pendingGame:1}},{multi:true})

    Games.remove({})
    Stats.remove({})
    Stats.insert({numGames:0})

    Meteor.setInterval (->
      numGames = Games.find({},{_id:1}).fetch().length
      numUsers = Users.find({heartbeat:{$ne:null}},{_id:1}).fetch().length
      Stats.update({},{$set:{numGames:numGames,numUsers:numUsers}})
    ),1000

