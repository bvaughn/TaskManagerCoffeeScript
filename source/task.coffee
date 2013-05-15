# Assists in the creation of getter/setter properties
Function::property = (prop, desc) ->
  Object.defineProperty @prototype, prop, desc

class Task extends EventDispatcher
  @uid: 0
  
  constructor: ( @_taskIdentifier ) ->
    @_id = ++Task.uid

    @_data = null
    @_message = null

    # State variables
    @_completed   = false
    @_errored     = false
    @_interrupted = false
    @_running     = false

    # State change counters
    @_numTimesCompleted   = 0
    @_numTimesErrored     = 0
    @_numTimesInterrupted = 0
    @_numTimesStarted     = 0

    # State-change handlers
    @_completeHandlers  = []
    @_errorHandlers     = []
    @_finalHandlers     = []
    @_interruptHandlers = []
    @_startHandlers     = []

  ###
  Override this method to give your Task functionality.
  ###
  customRun: ->

  ###
  Starts a task.
  This method may also be used to retry/resume an errored task.
  ###
  run: ->
    @_running = true

    @customRun()

    return this

  ###
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  ###

  @property 'id',
    get: ->
      return @_id

  @property 'data',
    get: ->
      return @_data

  @property 'message',
    get: ->
      return @_message

  @property 'taskIdentifier',
    get: ->
      return @_taskIdentifier

  @property 'completed',
    get: ->
      return @_completed

  @property 'errored',
    get: ->
      return @_errored

  @property 'interrupted',
    get: ->
      return @_interrupted

  @property 'running',
    get: ->
      return @_running

  @property 'numTimesCompleted',
    get: ->
      return @_numTimesCompleted
	
  @property 'numTimesErrored',
    get: ->
      return @_numTimesErrored
		
  @property 'numTimesInterrupted',
    get: ->
      return @_numTimesInterrupted
			
  @property 'numTimesStarted',
    get: ->
      return @_numTimesStarted

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
    if @_completeHandlers.indexOf( closure ) < 0
      @_completeHandlers.push( closure )
    return this

  removeCompleteHandler: (closure) ->
    if @_completeHandlers.indexOf( closure ) >= 0
      @_completeHandlers.splice( @_completeHandlers.indexOf( closure ), 1 )

  ###
  The provided function will be invoked only upon failure of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withErrorHandler: (closure) ->
    if @_errorHandlers.indexOf( closure ) < 0
      @_errorHandlers.push( closure )
    return this

  removeErrorHandler: (closure) ->
    if @_errorHandlers.indexOf( closure ) >= 0
      @_errorHandlers.splice( @_errorHandlers.indexOf( closure ), 1 )

  ###
  This handler is invoked upon either success or failure of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withFinalHandler: (closure) ->
    if @_finalHandlers.indexOf( closure ) < 0
      @_finalHandlers.push( closure )
    return this

  removeFinalHandler: (closure) ->
    if @_finalHandlers.indexOf( closure ) >= 0
      @_finalHandlers.splice( @_finalHandlers.indexOf( closure ), 1 )

  ###
  The provided function will be invoked only upon interruption of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withInterruptHandler: (closure) ->
    if @_interruptHandlers.indexOf( closure ) < 0
      @_interruptHandlers.push( closure )
    return this

  removeInterruptHandler: (closure) ->
    if @_interruptHandlers.indexOf( closure ) >= 0
      @_interruptHandlers.splice( @_interruptHandlers.indexOf( closure ), 1 )

  ###
  The provided function will be invoked each time the task is started (or re-started).
  Function can accept 0 arguments or 1 argument (the current Task)
  ###
  withStartHandler: (closure) ->
    if @_startHandlers.indexOf( closure ) < 0
      @_startHandlers.push( closure )
    return this

  removeStartHandler: (closure) ->
    if @_startHandlers.indexOf( closure ) >= 0
      @_startHandlers.splice( @_startHandlers.indexOf( closure ), 1 )

  ###
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  ###

  ###
  Returns a closure with the appropriate `this` scope.
  This convenience method is useful for attaching state-change listeners.
  ###
  wrapper: (closure) ->
    scope = this
    return `function() {
      closure.apply( scope, arguments );
    }`

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
      completeHandler( this )

    for finalHandler in @_finalHandlers
      finalHandler( this )

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
      errorHandler( this )

    for finalHandler in @_finalHandlers
      finalHandler( this )