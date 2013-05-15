class CompositeTask extends Task

  constructor: ( @_taskQueue = [], @_executeTaskInParallel = true, @_taskIdentifier ) ->
    super( @_taskIdentifier )

    @_addTasksBeforeRunInvoked = false
    @_erroredTasks = []
    @_flushTaskQueueLock = false
    @_taskQueueIndex = 0

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

  ###
  No incomplete Tasks remain in the queue.
  ###
  @property 'allTasksAreCompleted',
    get: ->
      for task in @_taskQueue
        if !task.completed
          return false
      return true

  ###
  References the Task that is currently running (if this CompositeTask has been told to execute in serial).
  ###
  @property 'currentSerialTask',
    get: ->
      if @_taskQueue.length > @_taskQueueIndex
        return @_taskQueue[ @_taskQueueIndex ]
      else
        return null

  ###
  Unique error messages from all inner Tasks that failed during execution.
  This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  ###
  @property 'errorMessages',
    get: ->
      returnArray = []
      for task in @_erroredTasks
        returnArray.push( task.message )
      return returnArray

  ###
  Error datas from all inner Tasks that failed during execution.
  This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  ###
  @property 'errorDatas',
    get: ->
      returnArray = []
      for task in @_erroredTasks
        returnArray.push( task.data )
      return returnArray

  ###
  Tasks that errored during execution.
  This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  ###
  @property 'erroredTasks',
    get: ->
      return @_erroredTasks

  ###
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  ###

  addTaskEventListeners: (task) ->
    task.withCompleteHandler( @wrapper( @_individualTaskCompleted ) )
    task.withErrorHandler( @wrapper( @_individualTaskCompleteded ) )
    task.withStartHandler( @wrapper( @_individualTaskStarted ) )

  checkForTaskCompletion: ->
    if @_flushTaskQueueLock
      return

    if @_taskQueue.length >= @_taskQueueIndex + 1 + @_erroredTasks.length
      return

    if @_erroredTasks.length > 0
      @taskError( errorMessages, errorDatas )
    else
      @taskComplete()

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

  removeTaskEventListeners: (task) ->
    task.removeCompleteHandler( @wrapper( @_individualTaskCompleted ) )
    task.removeErrorHandler( @wrapper( @_individualTaskCompleteded ) )
    task.removeStartHandler( @wrapper( @_individualTaskStarted ) )

  ###
  Individual Task event handlers
  ###

  _individualTaskCompleted: (task) ->
    @handleTaskCompletedOrRemoved( task )

  _individualTaskErrored: (task) ->
    # TODO

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