class TaskWithClosure extends Task

  constructor: ( @customRunFunction, @_autoCompleteAfterRunningFunction = false, @_taskIdentifier ) ->
    super( @_taskIdentifier )

  customRun: ->
    @customRunFunction()

    if @_autoCompleteAfterRunningFunction
      @taskComplete()