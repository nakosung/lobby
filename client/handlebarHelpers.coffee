Handlebars.registerHelper 'sessionGet', (x) ->
  Session.get(x)

Handlebars.registerHelper 'not', (x) ->
  not x

Handlebars.registerHelper 'moment', (x) ->
  moment x

Handlebars.registerHelper 'eq', (x,y) ->
  x == y

Handlebars.registerHelper 'neq', (x,y) ->
  x != y