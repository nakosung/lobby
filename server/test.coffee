Bot = {}
Bot.add = (id,options) ->
  silent = options?.silent? or true
  User.conditionalLeaveGame(id)
  seq = []
  seq.push ->
    Game.quickMatch(id)
    5000
  seq.push ->
    User.conditionalLeaveGame(id)
  f = ->
    User.keepAlive(id)
    g = _.shuffle(seq)[0]
    timeout = 1000
    try
      timeout = g() or timeout
    catch e
      console.log "#{e.error}" unless silent

    Meteor.setTimeout f, timeout

  f()

Meteor.autorun ->
  n = Users.find({testbot:true},{_id:1}).fetch().length
  _.each _.range(n,100), ->
    try
      Users.insert({name:"Bot#{_.random(1000000)}",testbot:true})
    catch e
      console.log 'dup bot'

  Users.find({testbot:true}).observeChanges
    added: (id) ->
      try
        Bot.add(id)



