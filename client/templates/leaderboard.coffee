Template.leaderboard.helpers
  'users' : ->
    Users.find({heartbeat:{$ne:undefined}},{sort:{heartbeat:1},limit:10})
