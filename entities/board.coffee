Meteor.methods
  'writeBoard' : (bid,text) ->
    article = {writer:@userId,text:text,createdAt:Date.now()}

    # deal with upsert
    if @isSimulation
      if Boards.findOne(bid)
        Boards.update(bid,{$push:articles:article})
      else
        Boards.insert(bid,{articles:[particle]})
    else
      Boards.update(bid,{$push:articles:article},{upsert:true})

      if bid != @userId
        u = Users.findOne(bid,{name:1})
        User.notify(u._id,"#{u.name} wrote on your board") if u

