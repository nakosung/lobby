graph =
  'init lobby' : ->

  'lobby game' : ->
    Game.quickMatch(@id)
    3000

  'game ready' : ->
    Game.readyForGame(Users.findOne(@id).game,@id)

  'game lobby' : ->
    User.conditionalLeaveGame(@id)

G = {}

_.each graph, (v,k) ->
  states = k.split(' ')
  from = states[0]
  to = states[1]
  G[from] ?= {}
  G[to] ?= {}
  G[from][to] = v

Bot = {}
Bot.add = (id,options) ->
  silent = options?.silent? or true
  User.conditionalLeaveGame(id)

  cursor = 'init'

  context =
    id:id

  f = ->
    User.keepAlive(id)
    to = _.shuffle(_.keys(G[cursor]))?[0]
    to ?= 'init'
    g = G[cursor][to]

    cursor = to
    timeout = 1000
    try
      timeout = g.call(context) or timeout
    catch e
      console.log "#{e.error}" unless silent

    Meteor.setTimeout f, timeout

  f()

if Meteor.isServer
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



