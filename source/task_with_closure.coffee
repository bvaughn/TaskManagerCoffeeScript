###
Task that invokes a specified function upon execution.
The function invoked will retain the scope of where it was defined, allowing for easy access to other class/method variables.

This type of Task can be asynchronous.
It will not complete (or error) until specifically instructed to do so.
This instruction should be triggered as a result of the custom function it executes.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class TaskWithClosure extends Task

  ###
  Constructor
  @param customRunFunction [Function] Function to be executed when this Task is run
  @param autoCompleteAfterRunningFunction [Boolean] If TRUE this Task will complete after running custom function (unless custom function called "errorTask")
  @param taskIdentifier [String] Optional human-readable label for Task-instance; can be useful for debugging or logging purposes
  ###
  constructor: ( @customRunFunction, @_autoCompleteAfterRunningFunction = false, @_taskIdentifier ) ->
    super( @_taskIdentifier )

  # @private
  customRun: ->
    @customRunFunction()

    if @_autoCompleteAfterRunningFunction
      @taskComplete()