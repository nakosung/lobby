Chat.chat = (uid,text,context) ->
  Chats.insert
    uid:uid
    text:text
    time:Date.now()
    context:context

  Chats._ensureIndex('context') unless @isSimulation

Meteor.methods
  'chat' : (text) ->
    u = Users.findOne(@userId)
    return unless u

    context = u.game
    Chat.chat.call(this,@userId,text,context)

if Meteor.isServer
  Meteor.startup ->
    Chats.remove {}