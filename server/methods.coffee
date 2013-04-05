Meteor.methods

  'createGame' : ->
    Game.create(@userId)

  'joinGame' : (gid) ->
    Game.join(gid,@userId)

  'leaveGame' : ->
    User.conditionalLeaveGame(@userId)

  'readyForGame' : ->
    gid = Users.findOne(@userId).game
    Game.readyForGame(gid,@userId) if gid

  'kickUser' : (uid) ->
    gid = Users.findOne(@userId).game
    Game.kick(gid,@userId,uid)

  'chat' : (text) ->
    Chat.chat(@userId,text)

  'changeProfile' : (options) ->
    Users.update(@userId,{$set:{name:options.name}}) if options.name and options.name.length > 2

  'popNotification' : ->
    result = Meteor.user().notifications[0]
    Meteor.users.update(@userId,{$pop:{notifications:1}})
    result

  'keepAlive' : ->
    Users.update(@userId,{$set:{heartbeat:Date.now()}})