voca =
  markPendingGame :
    commit: ->
      Users.update({_id:@uid,pendingGame:undefined},{$set:{pendingGame:@gid}})
      throw new Meteor.Error("user is already busy with other game room") unless Users.findOne({_id:@uid,pendingGame:@gid})
    rollback: ->
      Users.update({_id:@uid,pendingGame:@gid},{$unset:{pendingGame:1}})
    cleanup: ->
      Users.update({_id:@uid,pendingGame:@gid},{$unset:{pendingGame:1}})

  markFullIfSolo :
    commit: ->
      Games.update({_id:@gid,numUsers:1},{$set:{vacancy:0}})
    rollback: ->
      capacity = Games.findOne(@gid).maxCapacity
      Games.update({_id:@gid,numUsers:1},{$set:{vacancy:capacity - 1}})

  conditionalHandOffMaster :
    commit: ->
      # Hand off master if necessary
      count = 0
      while Games.findOne({_id:@gid,master:@uid})
        g = Games.findOne(@gid)

        # find out new master
        users = _.pluck(g.users,'uid')
        new_master = _.find(users,((u)=> u != @uid))

        break unless new_master

        Games.update {_id:@gid,master:@uid,users:{$elemMatch:{uid:new_master}}},
          $set:{master:new_master}

        throw new Meteor.Error("cannot hand off master") if count++ > 10

  unsetGame :
    commit: ->
      Users.update {_id:@uid,game:@gid}, {$unset:{game:1}}
    rollback: ->
      Users.update {_id:@uid,game:undefined}, {$set:{game:@gid}}

  removeFromGame :
    commit: ->
      Games.update {_id:@gid,users:{$elemMatch:{uid:@uid}}},
        $pull:{users:{uid:@uid}}
        $inc:{numUsers:-1,vacancy:1}

  pendJoin :
    commit: ->
      Games.update({_id:@gid,vacancy:{$gt:0},users:{$not:{$elemMatch:{uid:@uid}}}},{$push:{pendingJoin:@uid},$inc:{vacancy:-1}})
      g = Games.findOne({_id:@gid,pendingJoin:@uid})
      throw new Meteor.Error('no vacancy') unless g
    rollback: ->
      Games.update(gid,{$inc:{vacancy:1},$pull:{pendingJoin:@uid}})

  join :
    commit: ->
      Games.update @gid,
        $push:{users:{uid:@uid}}
        $inc:{numUsers:1}
        $pull:{pendingJoin:@uid}
    rollback: ->
      Games.update @gid,
        $pull:{users:{$elemMatch:{uid:@uid}}}
        $inc:{numUsers:-1}
        $push:{pendingJoin:@uid}

  setGame :
    commit: ->
      Users.update({_id:@uid},{$unset:{pendingGame:1},$set:{game:@gid}})

  create:
    commit: ->
      Games.insert
        _id:@gid
        master:@uid
        numUsers:1
        users:[{uid:@uid}]
        maxCapacity:@options.maxCapacity
        vacancy:@options.maxCapacity-1
        pendingJoin:[]
        createdAt:Date.now()
        title:@options.title



_.each voca, (v,k) ->
  this[k] = v