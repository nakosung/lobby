Meteor.methods
  'writeBoard' : (bid,text) ->
    article = {writer:@userId,text:text,createdAt:Date.now()}
    Boards.update(bid,{$push:articles:article},{upsert:true})

    u = Users.findOne(bid,{name:1})
    User.notify(u._id,"#{u.name} wrote on your board") if u
