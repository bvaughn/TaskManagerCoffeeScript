class Task
    @id: 0
    id: 0
    running: false
    constructor: ->
        @id = ++Task.id
    customRun: ->
        console.log "Not defined"
    run: ->
        @running = true
        @customRun()
        @running = false