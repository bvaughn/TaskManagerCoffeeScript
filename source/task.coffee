###
A Task is any operation that can be started and completed.
A Task may be a self-contained operation or it may be a composite of many such other Tasks.

To create a usable Task, extend this class and override the **customRun()**, **customReset()**, and **customInterrupt()** methods.
Your Task should call taskComplete() or taskError() upon completion.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class Task extends EventDispatcher

  get = (props) => @::__defineGetter__ name, getter for name, getter of props
  set = (props) => @::__defineSetter__ name, setter for name, setter of props

  @uid: 0
  
  ###
  Constructor
  @param taskIdentifier [String] Optional human-readable label for Task-instance; can be useful for debugging or logging purposes
  ###
  constructor: ( @_taskIdentifier ) ->
    @_id = ++Task.uid

    @_data = null
    @_message = null
    @_interruptingTask = null
    @_synchronous = false

    # State variables
    @_completed   = false
    @_errored     = false
    @_interrupted = false
    @_running     = false

    # State change counters
    @_numTimesCompleted   = 0
    @_numTimesErrored     = 0
    @_numTimesInterrupted = 0
    @_numTimesReset       = 0
    @_numTimesStarted     = 0

    # State-change handlers
    @_completeHandlers  = []
    @_errorHandlers     = []
    @_finalHandlers     = []
    @_interruptHandlers = []
    @_startHandlers     = []

  ###
  Resets the task to it's pre-run state.
  This allows it to be re-run.
  This method can only be called on non-running tasks.
  @return [Task] A reference to the current Task
  ###
  reset: ->
    if @running
      return

    if @numTimesStarted == 0
      return

    @_numTimesReset++

    @_completed   = false
    @_errored     = false
    @_interrupted = false

    @_numTimesCompleted   = 0
    @_numTimesErrored     = 0
    @_numTimesInterrupted = 0
    @_numTimesStarted     = 0

    @customReset()

    return this

  ###
  Starts a task.
  This method may be used to retry an errored Task or to resume an interrupted Task.
  @return [Task] A reference to the current Task
  ###
  run: ->
    if @_running
      return

    @_running = true
    @_numTimesStarted++

    @_interrupted = false
    @_running     = true

    for startHandler in @_startHandlers
      @executeTaskStateChangeClosure( startHandler )

    @customRun()

    return this

  ###
  -----------------------------------------------------------------
  Subclasses should override the following methods
  -----------------------------------------------------------------
  ###

  ###
  Override this method to give your Task functionality.
  @throw Error if not implemented
  ###
  customRun: ->
    throw "Tasks must implement customRun() method";

  ###
  Sub-classes should override this method to implement interruption behavior (removing event listeners, pausing objects, etc.).
  @throw Error if not implemented
  ###
  customInterrupt: ->
    throw "Tasks must implement customInterrupt() method";

  ###
  Override this method to perform any custom reset operations.
  @throw [Error] Error if not implemented
  ###
  customReset: ->
    throw "Tasks must implement customReset() method";

  ###
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  ###

  # @property [Boolean] The current task has successfully completed execution.
  get completed: -> @_completed

  # @property [Object] Optional data resulting from Task completion or failure.
  get data: -> @_data

  # @property [Boolean] The current Task failed.
  get errored: -> @_errored

  # @property [Integer] Unique ID for a Task.
  get id: -> @_id

  # @property [Boolean] The task has been interrupted and has not yet resumed.
  get interrupted: -> @_interrupted

  # @property [Task] The Task currently interrupting the this Task's execution (or NULL if no such Task exists).
  get interruptingTask: -> @_interruptingTask

  # @property [String] Optional message resulting from Task completion or failure.
  get message: -> @_message

  # @property [Integer] 
  # Number of internal operations conducted by this task.
  # Sub-classes should override this method if containing a value > 1;
  get numInternalOperations: -> 1

  # @property [Integer]
  # Number of internal operations that have completed.
  # Sub-classes should override this method if containing a value > 1;
  get numInternalOperationsCompleted: -> @completed ? 1 : 0

  # @property [Integer] Number of internal operations not yet completed.
  get numInternalOperationsPending: -> @numInternalOperations - @numInternalOperationsCompleted

  # @property [Integer] Number of times this task has completed.
  get numTimesCompleted: -> @_numTimesCompleted

  # @property [Integer] Number of times this task has errored.
  get numTimesErrored: -> @_numTimesErrored

  # @property [Integer] Number of times this task has been interrupted.
  get numTimesInterrupted: -> @_numTimesInterrupted

  # @property [Integer]
  # Number of times this task has been reset.
  # This is the only counter that is not reset by the reset() method.
  get numTimesReset: -> @_numTimesReset

  # @property [Integer] Number of times this task has been started.
  get numTimesStarted: -> @_numTimesStarted

  # @property [Boolean]
  # The task is currently running.
  # This value is FALSE if the task has not been run, has completed run (succesfully or due to a failure), or has been interrupted.
  get running: -> @_running

  # @property [Boolean] The current task can be executed synchronously.
  get synchronous: -> @_synchronous

  # @property [String] (Optional) human-readable label for task.
  get taskIdentifier: -> @_taskIdentifier
  set taskIdentifier: (@_taskIdentifier) ->

  ###
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  ###

  ###
  The provided function will be invoked only upon successful completion of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  @param closure [Closure] Function with "this" scope
  ###
  withCompleteHandler: (closure) ->
    @addClosureToSet( @_completeHandlers, closure )
    return this

  removeCompleteHandler: (closure) ->
    @removeClosureFromSet( @_completeHandlers, closure )
    return this

  ###
  The provided function will be invoked only upon failure of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  @param closure [Closure] Function with "this" scope
  ###
  withErrorHandler: (closure) ->
    @addClosureToSet( @_errorHandlers, closure )
    return this

  removeErrorHandler: (closure) ->
    @removeClosureFromSet( @_errorHandlers, closure )
    return this

  ###
  This handler is invoked upon either success or failure of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  @param closure [Closure] Function with "this" scope
  ###
  withFinalHandler: (closure) ->
    @addClosureToSet( @_finalHandlers, closure )
    return this

  removeFinalHandler: (closure) ->
    @removeClosureFromSet( @_finalHandlers, closure )
    return this

  ###
  The provided function will be invoked only upon interruption of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  @param closure [Closure] Function with "this" scope
  ###
  withInterruptHandler: (closure) ->
    @addClosureToSet( @_interruptHandlers, closure )
    return this

  removeInterruptHandler: (closure) ->
    @removeClosureFromSet( @_interruptHandlers, closure )
    return this

  ###
  The provided function will be invoked each time the task is started (or re-started).
  Function can accept 0 arguments or 1 argument (the current Task)
  @param closure [Closure] Function with "this" scope
  ###
  withStartHandler: (closure) ->
    @addClosureToSet( @_startHandlers, closure )
    return this

  removeStartHandler: (closure) ->
    @removeClosureFromSet( @_startHandlers, closure )
    return this

  ###
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  ###

  ###
  Adds the specified function (or Closure) to the specified Array
  @private
  ###
  addClosureToSet: (closures, closureToAdd) ->
    unless closureToAdd instanceof Closure
      closureToAdd = new Closure( closureToAdd, this )

    for closure in closures
      if closure.equals( closureToAdd )
        return

    closures.push( closureToAdd )

  ###
  Executes a function or a Closure (with inner function)
  @private
  ###
  executeTaskStateChangeClosure: (closure) ->
    closure.execute( this )

  ###
  Removes the specified function (or Closure) from the specified Array
  @private
  ###
  removeClosureFromSet: (closures, closureToRemove) ->
    unless closureToRemove instanceof Closure
      closureToRemove = new Closure( closureToRemove, this )

    for closure, index in closures
      if closure.equals( closureToRemove )
        closures.splice( index, 1 )
        break

  ###
  -----------------------------------------------------------------
  State change helper methods
  -----------------------------------------------------------------
  ###

  # This method should be called upon Task completion.
  # Typically this method should only be called by a Task, internally.
  # It triggers complete handlers and toggles the Tasks's "running" and "complete" states.
  taskComplete: ( message = "", data = null ) ->
    if !@_running
      return

    @_data = data
    @_message = message

    @_completed   = true
    @_errored     = false
    @_interrupted = true
    @_running     = false

    @_numTimesCompleted++;
    
    for completeHandler in @_completeHandlers
      @executeTaskStateChangeClosure( completeHandler )

    @dispatchEvent( new TaskEvent( TaskEvent.COMPLETE ) )

    for finalHandler in @_finalHandlers
      @executeTaskStateChangeClosure( finalHandler )

    @dispatchEvent( new TaskEvent( TaskEvent.FINAL ) )

  # This method should be called upon Task failure.
  # Typically this method should only be called by a Task, internally.
  # It triggers complete handlers and toggles the Tasks's "running" and "complete" states.
  taskError: ( message = "", data = null ) ->
    if !@_running
      return

    @_data = data
    @_message = message

    @_completed   = false
    @_errored     = true
    @_interrupted = true
    @_running     = false

    @_numTimesErrored++;

    for errorHandler in @_errorHandlers
      @executeTaskStateChangeClosure( errorHandler )

    @dispatchEvent( new TaskEvent( TaskEvent.ERROR ) )

    for finalHandler in @_finalHandlers
      @executeTaskStateChangeClosure( finalHandler )

    @dispatchEvent( new TaskEvent( TaskEvent.FINAL ) )