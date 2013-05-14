class CompositeTask extends Task
    constructor: (@tasks) ->
        super
    customRun: ->
        # TODO: Block for completion
        for task in @tasks
            task.run()