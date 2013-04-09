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

  if options?.title
    Games.update(gid,{$set:{title:options?.title}})

  if options?.maxCapacity
    target = options?.maxCapacity
    diff = target - g.maxCapacity
    requiredVacancy = if diff < 0 then -diff else 0
    Games.update {_id:gid,maxCapacity:g.maxCapacity,vacancy:{$gt:requiredVacancy}},
      $inc:{maxCapacity:diff,vacancy:diff}
    throw new Meteor.Error('failed to modify maxCapacity') unless Games.findOne {_id:gid,maxCapacity:target}

Game.join = (gid,uid) ->
  stage = 1

  try
    # set pending game
    Users.update({_id:uid,game:undefined,pendingGame:undefined},{$set:{pendingGame:gid}})
    throw new Meteor.Error("user is already busy with other game room") unless Users.findOne({_id:uid,pendingGame:gid})

    stage = 2

    Games.update({_id:gid,vacancy:{$gt:0}},{$push:{pendingJoin:uid},$inc:{vacancy:-1}})
    g = Games.findOne({_id:gid,pendingJoin:uid})
    throw new Meteor.Error('no vacancy') unless g

    stage = 3

    Games.update gid,
      $push:{users:{uid:uid}}
      $inc:{numUsers:1}
      $pull:{pendingJoin:uid}

    Users.update({_id:uid},{$unset:{pendingGame:1},$set:{game:gid}})

    stage = 4

  finally
    if stage == 3
      Games.update(gid,{$inc:{vacancy:1},$pull:{pendingJoin:uid}})

    if stage > 1
      Users.update(uid,{$unset:{pendingGame:1}})

    Game.conditionalDestroy(gid) if stage < 4


Game.conditionalDestroy = (gid) ->
  Games.remove({_id:gid,users:[],pendingJoin:[]})

Game.leave = (gid,uid) ->
  stage = 1

  try
    # set pending game
    Users.update({_id:uid,game:gid,pendingGame:undefined},{$set:{pendingGame:gid}})
    throw new Meteor.Error("user is already busy with other game room") unless Users.findOne({_id:uid,game:gid})

    stage = 2

    Games.update {_id:gid,users:{$elemMatch:{uid:uid}}},
      $pull:{users:{uid:uid}}
      $inc:{numUsers:-1,vacancy:1}

    # Destroy room if necessary
    Game.conditionalDestroy(gid)

    # Hand off master if necessary
#    if g.master == uid
#      new_master = _.find(_.pluck(g.users,'uid'),((u)->u != uid))
#      if not _.isUndefined(new_master)
#        Games.update {_id:gid,master:uid,users:{$elemMatch:{uid:new_master}}}, {$set:{master:new_master}}
#        User.notify(new_master,"You are the master of this room")

    Users.update {_id:uid,game:gid}, {$unset:{game:1}}
  finally
    if stage > 1
      Users.update(uid,{$unset:{pendingGame:1}})

Game.create = (uid,options) ->
  User.conditionalLeaveGame(uid)

  gid = Games.insert
    master:uid
    numUsers:1
    users:[{uid:uid}]
    maxCapacity:16
    vacancy:15
    pendingJoin:[]
    createdAt:Date.now()
    title:options?.title or grabSomeTitle()

  Users.update({_id:uid,pendingGame:undefined,game:undefined},{$set:{game:gid}})

  if not Users.findOne({_id:uid,game:gid})
    Games.remove(gid)
    throw new Meteor.Error("User is busy")

  gid

Game.kick = (gid,uid,target) ->
  throw new Meteor.Error("Can't kick yourself") if uid == target

  Games.update {_id:gid,users:{$elemMatch:{uid:uid}},master:uid},
    $pull:{users:{uid:target}}
    $inc:{numUsers:-1,vacancy:1}

  Users.update {_id:target,game:gid},
    $unset:{game:1}

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
    if @isSimulation
      Users.update(@userId,{$set:{game:gid}})
    else
      Game.join(gid,@userId)

  'game.quick' : () ->
    Game.quickMatch.call(this,@userId) unless @isSimulation

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

