# Assists in the creation of getter/setter properties
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

class Task extends EventDispatcher
  @uid: 0
  
  ###
  Constructor
  ###
  constructor: ( @_taskIdentifier ) ->
    @_id = ++Task.uid

    @_data = null
    @_message = null
    @_interruptingTask = null

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
  This method may also be used to retry/resume an errored task.
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
  ###
  customRun: ->
    throw "Tasks must implement customRun() method";

  ###
  Sub-classes should override this method to implement interruption behavior (removing event listeners, pausing objects, etc.).
  ###
  customInterrupt: ->
    throw "Tasks must implement customInterrupt() method";

  ###
  Override this method to perform any custom reset operations.
  ###
  customReset: ->
    throw "Tasks must implement customReset() method";

  ###
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  ###

  @property 'completed',
    get: ->
      return @_completed

  @property 'data',
    get: ->
      return @_data

  @property 'errored',
    get: ->
      return @_errored

  @property 'id',
    get: ->
      return @_id

  @property 'interrupted',
    get: ->
      return @_interrupted

  @property 'interruptingTask',
    get: ->
      return @_interruptingTask

  @property 'message',
    get: ->
      return @_message

  @property 'numInternalOperations',
    get: ->
      return 1

  @property 'numInternalOperationsCompleted',
    get: ->
      return @completed ? 1 : 0

  @property 'numInternalOperationsPending',
    get: ->
      return @numInternalOperations - @numInternalOperationsCompleted

  @property 'numTimesCompleted',
    get: ->
      return @_numTimesCompleted
	
  @property 'numTimesErrored',
    get: ->
      return @_numTimesErrored
		
  @property 'numTimesInterrupted',
    get: ->
      return @_numTimesInterrupted

  @property 'numTimesReset',
    get: ->
      return @_numTimesReset

  @property 'numTimesStarted',
    get: ->
      return @_numTimesStarted

  @property 'running',
    get: ->
      return @_running

  @property 'taskIdentifier',
    get: ->
      return @_taskIdentifier
    set: (value) ->
      @_taskIdentifier = value

  ###
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  ###

  ###
  The provided function will be invoked only upon successful completion of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withCompleteHandler: (closure) ->
    @addFunctionOrClosure( @_completeHandlers, closure )
    return this

  removeCompleteHandler: (closure) ->
    @removeFunctionOrClosure( @_completeHandlers, closure )
    return this

  ###
  The provided function will be invoked only upon failure of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withErrorHandler: (closure) ->
    @addFunctionOrClosure( @_errorHandlers, closure )
    return this

  removeErrorHandler: (closure) ->
    @removeFunctionOrClosure( @_errorHandlers, closure )
    return this

  ###
  This handler is invoked upon either success or failure of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withFinalHandler: (closure) ->
    @addFunctionOrClosure( @_finalHandlers, closure )
    return this

  removeFinalHandler: (closure) ->
    @removeFunctionOrClosure( @_finalHandlers, closure )
    return this

  ###
  The provided function will be invoked only upon interruption of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withInterruptHandler: (closure) ->
    @addFunctionOrClosure( @_interruptHandlers, closure )
    return this

  removeInterruptHandler: (closure) ->
    @removeFunctionOrClosure( @_interruptHandlers, closure )
    return this

  ###
  The provided function will be invoked each time the task is started (or re-started).
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withStartHandler: (closure) ->
    @addFunctionOrClosure( @_startHandlers, closure )
    return this

  removeStartHandler: (closure) ->
    @removeFunctionOrClosure( @_startHandlers, closure )
    return this

  ###
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  ###

  ###
  Adds the specified function (or Closure) to the specified Array
  ###
  addFunctionOrClosure: (functionAndClosures, functionOrClosureToAdd) ->
    if functionOrClosureToAdd instanceof Closure
      for functionOrClosure, index in functionAndClosures
        if functionOrClosure instanceof Closure && functionOrClosure.equals( functionOrClosureToAdd )
          return
    else
      if functionAndClosures.indexOf( functionOrClosureToAdd ) >= 0
        return
    functionAndClosures.push( functionOrClosureToAdd )

  ###
  Executes a function or a Closure (with inner function)
  ###
  executeTaskStateChangeClosure: (closure) ->
    if closure instanceof Closure
      closure.execute( this )
    else
      closure( this )

  ###
  Returns a closure with the appropriate `this` scope.
  This convenience method is useful for attaching state-change listeners.
  ###
  wrapper: (closure) ->
    return new Closure( closure, this )

  ###
  Removes the specified function (or Closure) from the specified Array
  ###
  removeFunctionOrClosure: (functionAndClosures, functionOrClosureToRemove) ->
    if functionOrClosureToRemove instanceof Closure
      for functionOrClosure, index in functionAndClosures
        if functionOrClosure instanceof Closure && functionOrClosure.equals( functionOrClosureToRemove )
          functionAndClosures.splice( index, 1 )
          break
    else
      if functionAndClosures.indexOf( functionOrClosureToRemove ) >= 0
        functionAndClosures.splice( functionAndClosures.indexOf( functionOrClosureToRemove ), 1 )

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

    for finalHandler in @_finalHandlers
      @executeTaskStateChangeClosure( finalHandler )

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

    for finalHandler in @_finalHandlers
      @executeTaskStateChangeClosure( finalHandler )