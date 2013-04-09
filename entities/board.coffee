Meteor.methods
  'writeBoard' : (bid,text) ->
    # upsert isn't supported yet, so simulation is disabled for now
    return if @isSimulation

    article = {writer:@userId,text:text,createdAt:Date.now()}
    Boards.update(bid,{$push:articles:article},{upsert:true})

    if bid != @userId
      u = Users.findOne(bid,{name:1})
      User.notify(u._id,"#{u.name} wrote on your board") if u

