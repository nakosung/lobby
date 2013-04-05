Meteor.publish 'userData', ->
  Users.find(@userId,{fields:{game:1,name:1}})

Meteor.publish 'publicUserData', ->
  Users.find({},{name:1})

Meteor.publish 'games', ->
  Games.find({users:{$ne:[]}})

Meteor.publish 'chats', ->
  Chats.find({})

Meteor.publish 'profile', (uid) ->
  Users.find(uid,{})

console.log "###################"