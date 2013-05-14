class TaskWithClosure extends Task
    constructor: (@closure) ->
        super
    customRun: ->
        @closure()