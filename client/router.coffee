TestRouter = Backbone.Router.extend
  routes:
    '' : 'main'
    'Leaderboard' : 'leaderboard'
  main: ->
    $('.modal').modal('hide')
    Session.set('leaderboard')

  leaderboard: ->
    $('.modal').modal('hide')
    Session.set('leaderboard',1)


Router = new TestRouter
window.Router = Router
Meteor.startup ->
  Backbone.history.start({pushState:true})