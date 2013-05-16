###
Base class for objects supporting event dispatching.

Big thanks to [adrianwiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/) for inspiring this class.
###
class EventDispatcher

  ###
  @private
  ###
  constructor: ->
    @closures = {}
 
  ###
  Registers callback for specified eventType.
  @param eventType [String] Event type / name
  @param callback [Function] Function accepting 1 parameter of type `Event`
  @param thisScope [Object] The *this* scope to apply to the callback method
  ###
  addListener: (eventType, callback, thisScope) ->
    if not @closures[eventType]
      @closures[eventType] = []

    newClosure = new Closure( callback, thisScope )
    
    for closure in @closures
      if closure.equals( newClosure )
        return

    @closures[eventType].push( newClosure )
  
  ###
  Removes registered callback for specified eventType.
  @param eventType [String] Event type / name
  @param callback [Function] Function
  @param thisScope [Object] The *this* scope to apply to the callback method
  ###
  removeListener: (eventType, callback, thisScope) ->
    return unless this.hasListeners( eventType )

    newClosure = new Closure( callback, thisScope )

    for closure, index in @closures
      if closure.equals( newClosure )
        @closures.splice( index, 1 )
        break
 
  ###
  Invokes all registered callbacks for specified event.
  @param event [Event] Event to dispatch
  ###
  dispatch: (event) ->
    return unless this.hasListeners( eventType )

    event.target = this

    closure.execute( event ) for closure in @closures[ event.eventType ]
 
  ###
  Returns true if there are any callbacks registered for specified eventType.
  @param eventType [String] Event type / name
  ###
  hasListeners: (eventType) ->
    @closures[ eventType ] and @closures[ eventType ].length > 0
 
  ###
  Removes all registered callbacks.
  ###
  removeAllListeners: ->
    @closures = {}