Clan.create = (uid,options) ->
  name = options?.name or 'anonymous'
  throw new Meteor.Error("should leave clan first") if Users.findOne(uid).clan
  throw new Meteor.Error("invalid name") if name.length < 3
  throw new Meteor.Error("Name already exists") unless Clans.findOne({name:name},{_id:1})

  cid = Clans.insert(
    master:uid
    name:name
    users:[{uid:uid}]
  )

  Users.update(uid,{$set:{clan:cid}})
  cid

Clan.is_member_of = (cid,uid) ->
  !!Clans.findOne({_id:cid,users:{$elemMatch:{uid:uid}}})

Clan.join = (cid,uid) ->
  throw new Meteor.Error("should leave clan first") if Users.findOne(uid).clan
  throw new Meteor.Error('already joined') if Clan.is_member_of(cid,uid)

  Clans.update(cid,{$addToSet:{users:{uid:uid}}})

  Users.update(uid,{$set:{clan:cid}})

Clan.leave = (cid,uid) ->
  throw new Meteor.Error('not a member of') unless Clan.is_member_of(cid,uid)

  c = Clans.findOne(cid)

  Clans.update(cid,{$pull:{users:{uid:uid}}})

  # Hand off master if necessary
  if c.master == uid
    new_master = _.find(_.pluck(c.users,'uid'),((u)->u != uid))
    Clans.update({_id:cid,master:uid},{$set:{master:new_master}})
    User.notify(new_master,"You are the master of this clan")

  Users.update({_id:uid,clan:cid},{$unset:{clan:1}})

  Clans.remove({_id:cid,users:[]})

Clan.kick = (cid,uid,target) ->
  c = Clans.findOne({_id:cid,master:uid})
  throw new Meteor.Error("No priviledge") unless c
  throw new Meteor.Error("Can't kick yourself") if uid == target

  Clan.leave(cid,target)
  User.notify(target,"Kicked out")
