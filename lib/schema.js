// Global variables
// - coffee-script has no way to do this.
Games = new Meteor.Collection('games')
Users = Meteor.users
Chats = new Meteor.Collection('chats')
Clans = new Meteor.Collection('clans')
Boards = new Meteor.Collection('boards')

User = {}
Game = {}
Chat = {}
Clan = {}
