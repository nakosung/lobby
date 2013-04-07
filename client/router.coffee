TestRouter = Backbone.Router.extend
  routes:
    '' : 'main'
    'Leaderboard' : 'leaderboard'
  main: ->
    Session.set('leaderboard')
    Session.set('user')
    Session.set('clan')
  leaderboard: ->
    Session.set('leaderboard',1)
    Session.set('user')
    Session.set('clan')

Router = new TestRouter
window.Router = Router
Meteor.startup ->
  Backbone.history.start({pushState:true})