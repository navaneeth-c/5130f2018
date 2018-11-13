Helper = require("hubot-test-helper")
helper = new Helper("../src")

expect = require("chai").expect

describe "powershell", ->

  beforeEach ->

    @room = helper.createRoom()

    @room.robot.brain.get "triggerTest",
      module: "moduleTest"


  afterEach ->
    @room.destroy()
# INCOMPLETE
  context "Fail if Role Does not exist", ->

    it "should return brain values", ->
      @room.user.say("alice", "hubot: register function hubotTest add sampleTrigger sampleRole").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: register function hubotTest add sampleTrigger sampleRole"]
          ["hubot", "@alice >*The Role group/Role does not exist.* \nPlease create the role group before assigning the role group to the function"]
        ]

  context "Number of arguments are less", ->

    it "Fail if the min number of arguments is not passed", ->
      @room.user.say("alice", "hubot: register function hubotTest add").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: register function hubotTest add"]
          ["hubot", "@alice >You have to give minimum of 3 parameters. Command for register your module: \n `register function <module name> <function name> <trigger name> <auth group(optional)>`"]
        ]
  context "Number of arguments are more", ->

    it "Fail if the number of arguments passed are more than expected", ->
      @room.user.say("alice", "hubot: register function hubotTest add test test test").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: register function hubotTest add test test test"]
          ["hubot", "@alice >You can enter only 4 parameters. Command for register your module: \n `register function <module name> <function name> <trigger name> <auth group(optional)>`"]
        ]

  context "Function call, Trigger does not exist", ->

    it "Fail if accessing trigger that does not exist", ->
      @room.user.say("alice", "hubot: function addTrig 4 5").then =>
        expect(@room.messages).to.eql [
          ["alice", "hubot: function addTrig 4 5"]
          ["hubot", "@alice  >Trigger does not exist. Please check the trigger Key"]
        ]
