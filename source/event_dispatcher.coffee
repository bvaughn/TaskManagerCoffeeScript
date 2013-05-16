###
Base class for objects supporting event dispatching.

@author [Brian Vaughn](http://www.briandavidvaughn.com), [Adrian Wiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/)
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
  addEventListener: (eventType, callback, thisScope) ->
    unless @closures
      @closures = {}

    unless @closures[eventType]
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
  removeEventListener: (eventType, callback, thisScope) ->
    unless @closures
      @closures = {}

    return unless @hasEventListeners( eventType )

    newClosure = new Closure( callback, thisScope )

    for closure, index in @closures
      if closure.equals( newClosure )
        @closures.splice( index, 1 )
        break
 
  ###
  Invokes all registered callbacks for specified event.
  @param event [Event] Event to dispatch
  ###
  dispatchEvent: (event) ->
    unless @closures
      @closures = {}

    return unless @hasEventListeners( event.eventType )

    event.target = this

    for closure in @closures[ event.eventType ]
      closure.execute( event )
 
  ###
  Returns true if there are any callbacks registered for specified eventType.
  @param eventType [String] Event type / name
  ###
  hasEventListeners: (eventType) ->
    unless @closures
      @closures = {}

    @closures[ eventType ] and @closures[ eventType ].length > 0
 
  ###
  Removes all registered callbacks.
  ###
  removeAllEventListeners: ->
    @closures = {}