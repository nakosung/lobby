Template.userHome.helpers
  'user' : ->
    Users.findOne(Session.get('user'))

  'isSelf' : ->
    Meteor.userId() == Session.get('user')

  'isFriend' : ->
    _.contains(Meteor.user()?.friends,Session.get('user'))

Template.userHome.rendered = ->
  $('.modal')
    .modal()
    .on 'hidden', ->
      Session.set('user')

Template.userHome.events
  'click .close' : ->
    $('.modal').modal('hide')

  'click .change' : (e) ->
    bootbox.prompt 'New name?', (result) ->
      if result
        Meteor.safeCall 'changeProfile', {name:result}

  'click .addFriend' : ->
    Meteor.safeCall 'friend.add', @_id

  'click .delFriend' : ->
    Meteor.safeCall 'friend.remove', @_id
