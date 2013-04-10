Template.inventory.helpers
  'items' : ->
    Items.find({owner:Meteor.userId()})

Template.inventory.events
  'click .dig' : ->
    Meteor.safeCall 'item.dig'
