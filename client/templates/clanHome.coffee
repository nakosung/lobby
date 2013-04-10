Template.clanHome.helpers
  'clan' : ->
    Clans.findOne(Session.get('clan'))

Template.clanHome.rendered = ->
  $('.modal')
    .modal()
    .on 'hidden', ->
      Session.set('clan')

Template.clanHome.events
  'click .close' : ->
    $('.modal').modal('hide')
  'click #joinClan' : ->
    Meteor.safeCall 'joinClan', @_id, (err,result) ->
      if err
        bootbox.alert(err.error)
      else
        bootbox.alert('welcome')

  'click #leaveClan' : ->
    Meteor.call 'leaveClan', (err,result) ->
      if err
        bootbox.alert(err.error)
      else
        $('.modal').modal('hide')
        bootbox.alert('you are freed from the clan')