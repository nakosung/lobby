Template.board.helpers
  'board' : ->
    Boards.findOne(String(this))

Template.board.events
  'submit' : (e) ->
    e.preventDefault()
    input = $('#boardText')
    text = input.val()
    input.val('')
    Meteor.safeCall 'writeBoard', String(this), text
