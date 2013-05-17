###
Base class for objects supporting event dispatching.

@author [Brian Vaughn](http://www.briandavidvaughn.com), [Adrian Wiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/)
###
class EventDispatcher

  ###
  @private
  ###
  constructor: ->
    @proxies = {}
 
  ###
  Registers method for specified eventType.
  @param eventType [String] Event type / name
  @param method [Function] Function accepting 1 parameter of type `Event`
  @param thisScope [Object] The *this* scope to apply to the callback method
  ###
  addEventListener: (eventType, method, thisScope) ->
    unless @proxies
      @proxies = {}

    unless @proxies[eventType]
      @proxies[eventType] = []

    newProxy = new Proxy( method, thisScope )
    
    for proxy in @proxies
      if proxy.equals( newProxy )
        return

    @proxies[eventType].push( newProxy )
  
  ###
  Removes registered method for specified eventType.
  @param eventType [String] Event type / name
  @param method [Function] Function
  @param thisScope [Object] The *this* scope to apply to the callback method
  ###
  removeEventListener: (eventType, method, thisScope) ->
    unless @proxies
      @proxies = {}

    return unless @hasEventListeners( eventType )

    newProxy = new Proxy( method, thisScope )

    for proxy, index in @proxies
      if proxy.equals( newProxy )
        @proxies.splice( index, 1 )
        break
 
  ###
  Invokes all registered methods for specified event.
  @param event [Event] Event to dispatch
  ###
  dispatchEvent: (event) ->
    unless @proxies
      @proxies = {}

    return unless @hasEventListeners( event.eventType )

    event.target = this

    for proxy in @proxies[ event.eventType ]
      proxy( event )
 
  ###
  Returns true if there are any methods registered for specified eventType.
  @param eventType [String] Event type / name
  ###
  hasEventListeners: (eventType) ->
    unless @proxies
      @proxies = {}

    @proxies[ eventType ] and @proxies[ eventType ].length > 0
 
  ###
  Removes all registered methods.
  ###
  removeAllEventListeners: ->
    @proxies = {}