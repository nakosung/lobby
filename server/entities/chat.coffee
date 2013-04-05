Chat.chat = (uid,text) ->
  Chats.insert({uid:uid,text:text,time:Date.now()})
