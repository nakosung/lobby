## Bring notifications on screen!
((outer)->
  showingNote = false
  outer.showNotifications = ->
    # guard re-entrance
    return if showingNote or not Meteor.user()

    note = Notifications.findOne({read:undefined})
    if note
      showingNote = true

      endUp = ->
        Notifications.update(note._id,{$set:{read:true}})
        showingNote = false
        Meteor.setTimeout (-> showNotifications()), 1000

      bootbox.alert note.message, ->
        endUp()
)(this)

Notifications.find({owner:Meteor.userId()}).observe
  added: ->
    showNotifications()

