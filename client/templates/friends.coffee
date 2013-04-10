Template.friends.helpers
  'hasAnyFriend' : ->
    Meteor.user()?.friends?.length > 0

  'friends' : ->
    f = Meteor.user()?.friends
    Users.find({_id:{$in:f}}) if f

