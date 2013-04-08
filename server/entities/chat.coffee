Chat.chat = (uid,text,context) ->
  Chats.insert
    uid:uid
    text:text
    time:Date.now()
    context:context

  Chats._ensureIndex('context')