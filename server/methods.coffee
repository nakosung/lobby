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
    Game.readyForGame(gid,@userId) if gid

  'game.kick' : (uid) ->
    gid = Users.findOne(@userId).game
    Game.kick(gid,@userId,uid)

  'chat' : (text) ->
    context = Users.findOne(@userId).game
    Chat.chat(@userId,text,context)

  'changeProfile' : (options) ->
    name = options?.name
    if name
      throw new Meteor.Error('invalid name') unless name.length > 2
      throw new Meteor.Error('name in use') if Users.findOne({name:name},{_id:1})
      Users.update(@userId,{$set:{name:name}})
      Users._ensureIndex({name:1},{unique:true})

  'keepAlive' : ->
    Users.update(@userId,{$set:{heartbeat:Date.now()}})

  'createClan' : (options) ->
    Clan.create(@userId,options)

  'joinClan' : (cid) ->
    Clan.join(cid,@userId)

  'leaveClan' : () ->
    Clan.leave(Users.findOne(@userId).clan,@userId)

  'kickFromClan' : (uid) ->
    Clan.kick(Users.findOne(@userId).clan,@userId,uid)

  'writeBoard' : (bid,text) ->
    article = {writer:@userId,text:text,createdAt:Date.now()}
    Boards.update(bid,{$push:articles:article},{upsert:true})

    u = Users.findOne(bid,{name:1})
    User.notify(u._id,"#{u.name} wrote on your board") if u

  'friend.add' : (uid) ->
    throw new Meteor.Error('self cannot be a friend') if @userId == uid

    Users.update(@userId,{$addToSet:{friends:uid}})

  'friend.remove' : (uid) ->
    throw new Meteor.Error('self cannot be a friend') if @userId == uid

    Users.update(@userId,{$pull:{friends:uid}})
