Template.navbar.helpers
  stats : ->
    Stats.findOne()

Template.navbar.events
  'click #createClan' : ->
    bootbox.prompt 'clan name?', (name) ->
      return unless name

      Meteor.safeCall 'createClan',
        name:name