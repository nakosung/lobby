Meteor.methods
  'game.edit' : (options) ->
    gid = Users.findOne(@userId).game
    Game.edit(gid,@userId,options)

  'game.create' : ->
    Game.create(@userId)

  'game.join' : (gid) ->
    Game.join(gid,@userId)

  'game.leave' : ->
    User.conditionalLeaveGame(@userId)

  'game.ready' : ->
    gid = Users.findOne(@userId).game
    Game.readyForGame(gid,@userId) if gid

  'game.kick' : (uid) ->
    gid = Users.findOne(@userId).game
    Game.kick(gid,@userId,uid)

  'chat' : (text) ->
    Chat.chat(@userId,text)

  'changeProfile' : (options) ->
    name = options?.name
    if name
      throw new Meteor.Error('invalid name') unless name.length > 2
      throw new Meteor.Error('name in use') if Users.findOne({name:name},{_id:1})
      Users.update(@userId,{$set:{name:name}})
      Users._ensureIndex({name:1},{unique:true})

  'popNotification' : ->
    result = Meteor.user().notifications[0]
    Meteor.users.update(@userId,{$pop:{notifications:1}})
    result

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