Template.chat.helpers
  chats : ->
    Chats.find()

Template.chat.events
  'submit' : (e) ->
    e.preventDefault()
    input = $('.input',$(e.target).parent())
    text = input.val()
    input.val('')

    Meteor.call 'chat',text if text != ""

Template.chat.rendered = ->
  chat = $(@find('.chatWindow'))
  chat.scrollTop chat.get(0).scrollHeight