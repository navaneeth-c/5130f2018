# Description
#   Assign roles to users and restrict command access in other scripts.
#
# Configuration:
# This can go in Jenkins
# Register your repository before using the install-module Function
# Register command using the following command:
# --Register-PSRepository -Name trial -SourceLocation "<Repo Url>" -PublishLocation "<Repo Url>"--
#
# Commands:
#   Function Register ->`hubot function register <module name> <function name> <trigger> <optional role group>` - Creates a trigger that binds Role Group - Module - Function (Only admins have the privelage for this)
#   Function Call ->`hubot function <trigger> <space seperated arguments>` - Calls the function if the user is authorized to call the specific function
#   Function Delete ->`hubot delete function <trigger>` - Removes the function trigger entry from brain. (Only users in functionDelete Role group have access to this command)
#   Function Details ->`hubot function details <role>` - List out the details of the function(function name, module, role group)
#   List Functions ->`hubot list functions` - Gives the list of functions registered in the bot
#

# CoffeScript code to register the repository:
#----------------------------------------------

  # ps = new shell(usePwsh: true)
  # ps.addCommand('Register-PSRepository -Name trial -SourceLocation "https://mia-repo.citrite.net/api/nuget/uco-local-nuget-powershell"').then(->
  #   ps.invoke()
  # ).then((output) ->
  #   console.log output
  #   msg.reply "Repo registered successfully"
  # ).catch (err) ->
  #   console.log err
  #   msg.send err
  #
  #   ps.dispose()
  #   return


# MongoDB Schema for the role:
#------------------------------
#"{
#   "id":"pwshData-<trigger name>",
#   "value":{
#       "module":"",
#       "function":"",
#       "authGroup":""
#    }
# }"
# id name for every trigger is saved with a prefix pwshData to differentiate the
# powershell function trigger from other values in the brain.
#
# -----------------------------------------------------------------------------
KeyVault = require("azure-keyvault")
msRestAzure = require("ms-rest-azure")
shell = require("node-powershellcore")
AuthenticationContext = require('adal-node').AuthenticationContext

module.exports = (robot) ->

  class Powershell

    isJsonString: (string) ->
      try
        JSON.parse(string)
      catch error
        return false
      return true

  # RUN/CALL THE POWERSHELL COMMAND
  # ---------------------------------
  # Only users authorized to call a specific function may call a function.
  #
  # Call accepts the following parameters:
  #
  # trigger ->
  # The trigger name for the function
  # argument list ->
  # This should accommodate parameters containing spaces by accepting single and double quotes
  #
  # #Important Note:
  #   -> The parameters that are gonna be passed into the function should be space seperated
  #       or it can contain spaces by accepting single and double quotes.

  robot.powershell = new Powershell

  robot.respond /list function[s]?/i,(msg)->
    Triggerlist = Object.keys(robot.brain.data._private)
    sizeOfList = Triggerlist.length
    flag = 0
    for trigger in Triggerlist
      if(trigger.startsWith("pwshData-"))
        flag = 1
        value = robot.brain.get(trigger)
        if (value != null)
          tName = trigger.substring(9)
          msg.reply " \n*Trigger Name:* #{tName} | *Module:* #{value.module} | *Function:* #{value.function} | *Role Group:* #{value.roleGroup}"
    if(flag == 0)
      msg.reply "_No function is registered yet_"

  robot.respond /delete function trigger (.*)/i, (msg)->
    functionDeleteRoleGroup = 'functionDelete'
    if(robot.auth.hasRole(msg.message.user, functionDeleteRoleGroup))
      triggerMatched = msg.match[1]
      powershellDataAppendText = 'pwshData-'
      triggerKey = powershellDataAppendText.concat(triggerMatched)

      # Retrive the value of the trigger which is stored using register->install-module function
      triggerValue = robot.brain.get(triggerKey)
      # console.log "the value of the trigger #{JSON.stringify triggerValue}"
      if(triggerValue == null)
        msg.reply "Trigger *#{triggerMatched}* does not exist. Please check your trigger name"
        return
      else
        robot.brain.remove(triggerKey)
        msg.reply "Function deleted Successfully"
    else
      msg.reply "You have no access to delete a function trigger. \nContact someone from *#{functionDeleteRoleGroup}* role to delete the function"


  robot.respond /function (\S*) (.*)?/i, (msg)->

    #Matching the Trigger Name(triggerMatched) and the parameters(matchString)
    triggerMatched = msg.match[1]
    matchString = msg.match[2]
    # paramsArray = matchString.split(" ")
    # result = matchString.match(/[^\s"']+|"([^"]*)"|'([^']*)'/gi)
    # paramsArray = result.join(" ")

    # The string 'pwshData-' is appened to the trigger to differentiate its values
    # from the other values in the DB
    powershellDataAppendText = 'pwshData-'
    triggerKey = powershellDataAppendText.concat(triggerMatched)

    # Retrive the value of the trigger which is stored using register->install-module function
    triggerValue = robot.brain.get(triggerKey)

    if(triggerValue == null)
      msg.reply " >Trigger does not exist. Please check the trigger Key"
      return

    # Check the role group whether the user have access to the command
    if(robot.auth.hasRole(msg.message.user,triggerValue.roleGroup) == false)
      msg.reply ">You dont have access to run this command. Please contact Role-group *#{triggerValue.roleGroup}'s* admin/owners to get your access"
      return

    # Create a pwsh(Linux/MacOS) shell instance to invoke the powershell commands
    ps = new shell(usePwsh: true)

    # Invoking the powershell Script
    # 'matchString' has the parameters for the powershell function which is appened
    # to the powershell command
    ps.addCommand("#{triggerValue.function} "+"#{matchString}").then(->
      ps.invoke()
    ).then((output) ->
      # Have to handle case if the payload doesnt have the property context.
      #

      if(robot.powershell.isJsonString output)
        output = JSON.parse output
        if(output.context.toUpperCase() == "VAULT")
          today = new Date
          timeStamp = today.getMonth()+1+"/"+today.getDate()+" "+today.getHours()+":"+today.getMinutes()+":"+today.getSeconds()
          secretName = triggerValue.function+timeStamp
          kvService.setSecret(secretName,output.payload)

        if output.context.toUpperCase() == "PM"
          robot.messageRoom msg.message.user.id, output.payload
          console.log ">Output sent in private message to the user"

        if output.context.toUpperCase() == "CHANNEL"
          msg.reply "*>Result:* #{output.payload}"

      else
        msg.reply "*>Result:* #{output}"
    ).catch (err) ->
      console.log err
      msg.send "Trigger Invoke failed"
      ps.dispose()
      return

  # REGISTER POWERSHELL MODULE AND FUNCTION
  # ---------------------------------------
  # Any user may call register to install a new function in to wesley.
  #
  # This call accepts the following params:
  #
  # module name -> The name of the powershell module
  # function name -> The name of the function within the powershell module to call
  # trigger -> The trigger keyword for the function
  # role group -> The role group which can call the function, if not specified anyone can call the function


  robot.respond /register function (.*)?/i, (msg)->
  # Matching the module name, function, trigger, role group from the user
    stringMatched = msg.match[1]
    paramsArray = stringMatched.split(" ")
    # check the parameters for no of parameter correctness
    if(paramsArray.length > 4)
      msg.reply ">You can enter only 4 parameters. Command for register your module: \n `register function <module name> <function name> <trigger name> <auth group(optional)>`"

      return
    if(paramsArray.length < 3)
      msg.reply ">You have to give minimum of 3 parameters. Command for register your module: \n `register function <module name> <function name> <trigger name> <auth group(optional)>`"
      return
    moduleName = paramsArray[0]
    functionName = paramsArray[1]
    trigger = paramsArray[2]
    roleGroup = paramsArray[3]

    # String 'roleData-' is used to differentiate the robot.auth ID's in brain
    if(roleGroup == null | roleGroup == undefined)
      msg.reply ">You didn't mention any role group. This function trigger will be accessible by anyone"
    else
      roleBrainText = 'roleData-'
      keyRoleName = roleBrainText.concat(roleGroup)
      # Retrive the Role data from Brain
      role = robot.brain.get(keyRoleName)

      # If the role value is empty then the role does not exist
      if (role == null)
        msg.reply ">*The Role group/Role does not exist.* \nPlease create the role group before assigning the role group to the function"
        return

    # Check if the trigger already exist
    # The string 'pwshData-' is appened to the trigger to differentiate its values
    # from the other values in the DB
    powershellDataAppendText = 'pwshData-'
    triggerKey = powershellDataAppendText.concat(trigger)
    triggerValue = robot.brain.get(triggerKey)

    # If the trigger already exists, then throw a friendly error
    if(triggerValue != null)
      msg.reply "_Trigger Name already exist_"
      return
    # Invoking the powershell Script
    # Creating a pwsh instance to make it work in Linux and MacOS
    ps = new shell(usePwsh: true)

    # Install-module will work only when the repsitory/artifactory is registered
    # Make sure register-PSRepository command is invoked before running install-module
    ps.addCommand("install-module -Name #{moduleName} -Scope CurrentUser -Force").then(->
      ps.invoke()
    ).then((output) ->
      msg.reply "Module #{moduleName} installed successfully"
      # Use Get-command to list the details of the function
      # check if the function exist inside the module
      # If the get-command returns nothing then it will be clear that the function does not exist in the module
      ps.addCommand("Get-command #{functionName}").then(->
        ps.invoke()
      ).then((output) ->
        console.log output
        msg.reply "Function *#{functionName}* registered to the trigger '#{trigger}'"
      ).catch (err) ->
        console.log err
        msg.send "Function *#{functionName}* does not exist in the module"
        ps.dispose()
        return
    ).catch (err) ->
      console.log err
      msg.send "The module is not installed successfully"
      ps.dispose()
      return
    # command to count the number of arguments
    ps.addCommand("(#{functionName} -Name Get-ChildItem).Parameters.count").then(->
      ps.invoke()
    ).then((output) ->
      console.log output
      noOfParameters = output
    ).catch (err) ->
      console.log err
      msg.send "Function *#{functionName}* does not exist in the module"
      ps.dispose()
      return
    console.log "no of parameters is #{noOfParameters}"

    # Check if the trigger already exist
    # The string 'pwshData-' is appened to the trigger to differentiate its values
    # from the other values in the DB
    powershellDataAppendText = 'pwshData-'
    triggerKey = powershellDataAppendText.concat(trigger)
    triggerValue = robot.brain.get(triggerKey)

    # Trigger data Schema designed to save the value in the DB
    triggerData =
      module:moduleName
      function:functionName
      roleGroup : roleGroup

    #If all the above is true then save the trigger in the brain
    robot.brain.set(triggerKey, triggerData)
