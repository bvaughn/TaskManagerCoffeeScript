###
Wraps a set of ITasks and executes them in parallel or serial, as specified by a boolean constructor arg.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class CompositeTask extends Task

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  ###
  Constructor.
  @param taskQueue [Array<Task>] Set of Tasks and/or functions to be executed.
  @param executeTaskInParallel [Boolean] Execute all Tasks at the same time; if this value is FALSE Tasks will be executed in serial.
  @param taskIdentifier [String] Optional human-readable label for Task-instance; can be useful for debugging or logging purposes.
  ###
  constructor: ( @_taskQueue = [], @_executeTaskInParallel = true, @_taskIdentifier ) ->
    super( @_taskIdentifier )

    @_addTasksBeforeRunInvoked = false
    @_erroredTasks = []
    @_flushTaskQueueLock = false
    @_taskQueueIndex = 0

  # @private
  customRun: ->
    if !@_addTasksBeforeRunInvoked
      @addTasksBeforeRun()
      @_addTasksBeforeRunInvoked = true

    if @_taskQueue.length == 0 || @allTasksAreCompleted
      @taskComplete()
      return
    
    @_erroredTasks = []

    for task in @_taskQueue
      @addTaskEventListeners( task )

    if @_executeTaskInParallel
      for task in @_taskQueue
        task.run()
    else
      @currentSerialTask.run()

  ###
  -----------------------------------------------------------------
  Getters / setters
  -----------------------------------------------------------------
  ###

  # @property [Boolean] No incomplete Tasks remain in the queue.
  get allTasksAreCompleted: ->
    for task in @_taskQueue
      if !task.completed
        return false
    return true

  # @property [Task] References the Task that is currently running (if this CompositeTask has been told to execute in serial).
  get currentSerialTask: ->
    if @_taskQueue.length > @_taskQueueIndex
      return @_taskQueue[ @_taskQueueIndex ]
    else
      return null

  # @property [Array<String>]
  # Unique error messages from all inner Tasks that failed during execution.
  # This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  get errorMessages: ->
    returnArray = []
    for task in @_erroredTasks
      returnArray.push( task.message )
    return returnArray

  # @property [Array<Object>]
  # Error datas from all inner Tasks that failed during execution.
  # This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  get errorDatas: ->
    returnArray = []
    for task in @_erroredTasks
      returnArray.push( task.data )
    return returnArray

  # @property [Array<Task>]
  # Tasks that errored during execution.
  # This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  get erroredTasks: -> @_erroredTasks

  ###
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  ###

  # @private
  addTaskEventListeners: (task) ->
    task.withCompleteHandler( new Proxy( @_individualTaskCompleted, this ) )
    task.withErrorHandler( new Proxy( @_individualTaskCompleteded, this ) )
    task.withStartHandler( new Proxy( @_individualTaskStarted, this ) )

  # @private
  checkForTaskCompletion: ->
    if @_flushTaskQueueLock
      return

    if @_taskQueue.length >= @_taskQueueIndex + 1 + @_erroredTasks.length
      return

    if @_erroredTasks.length > 0
      @taskError( errorMessages, errorDatas )
    else
      @taskComplete()

  # @private
  handleTaskCompletedOrRemoved: (task) ->
    @removeTaskEventListeners( task )

    # If this Task was removed before completion, don't call the Task-complete hook.
    if task.completed
      @individualTaskComplete( task )

    @_taskQueueIndex++

    # Handle edge-case where an inner Task's complete handler resulted in the composite's interruption
    if !@running
      return

    if @_executeTaskInParallel
      @checkForTaskCompletion()
    else
      if @currentSerialTask
        @currentSerialTask.run()
      else
        @checkForTaskCompletion()

  # @private
  removeTaskEventListeners: (task) ->
    task.removeCompleteHandler( new Proxy( @_individualTaskCompleted, this ) )
    task.removeErrorHandler( new Proxy( @_individualTaskCompleteded, this ) )
    task.removeStartHandler( new Proxy( @_individualTaskStarted, this ) )

  ###
  Individual Task event handlers
  ###

  # @private
  _individualTaskCompleted: (task) ->
    @handleTaskCompletedOrRemoved( task )

  # @private
  _individualTaskErrored: (task) ->
    # TODO

  # @private
  _individualTaskStarted: (task) ->
    # TODO

  ###
  Sub-classes may override the following methods
  ###

  # Override this method to J.I.T. add child Tasks before the composite Task is run.
  addTasksBeforeRun: ->

  # Override this method to be notified when individual Tasks have successfully completed.
  individualTaskComplete: ->

  # Override this method to be notified when individual Tasks are started.
  individualTaskStarted: ->