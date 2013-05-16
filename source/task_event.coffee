###
Dispatched by a Task to indicated a change in state.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class TaskEvent extends Event

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  ###
  A task has completed successfully.
  ###
  @COMPLETE: "TaskEvent.COMPLETE"

  ###
  A task has failed.
  ###
  @ERROR: "TaskEvent.ERROR"

  ###
  A task has either completed or failed.
  ###
  @FINAL: "TaskEvent.FINAL"

  ###
  A task has started running.
  ###
  @STARTED: "TaskEvent.STARTED"

  ###
  A Task has been interrupted.
  ###
  @INTERRUPTED: "TaskEvent.INTERRUPTED"

  # @property [Task] The Task this event is describing
  get task: -> @target