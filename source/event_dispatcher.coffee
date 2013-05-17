###
Dispatches `Event` objects and notifies exeternal listeners.
Extend this object to dispatch events to external listeners.

Special thanks to [Adrian Wiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/) for the initial idea.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
###
class EventDispatcher

  ###
  @private
  ###
  constructor: ->
    @proxies = {}

  ###
  Registers a listener for specified type of `Event`.
  @param eventType [String] `Event` type
  @param method [Function] Function accepting 1 parameter of type `Event`
  ###
  addEventListener: ( eventType, method ) ->
    unless @proxies
      @proxies = {}

    unless @proxies[eventType]
      @proxies[eventType] = []

    unless method instanceof Proxy
      method = new Proxy( method, this )
    
    for proxy in @proxies
      if proxy.equals( method )
        return

    @proxies[eventType].push( method )
  
  ###
  Removes registered method for specified eventType.
  @param eventType [String] `Event` type
  @param method [Function] Function accepting 1 parameter of type `Event`
  ###
  removeEventListener: ( eventType, method ) ->
    unless @proxies
      @proxies = {}

    return unless @hasEventListeners( eventType )

    unless method instanceof Proxy
      method = new Proxy( method, this )

    for proxy, index in @proxies
      if proxy.equals( method )
        @proxies.splice( index, 1 )
        break
 
  ###
  Dispatches the specified `Event` and notifies all listeners.
  @param event [Event] `Event` to dispatch
  ###
  dispatchEvent: (event) ->
    unless @proxies
      @proxies = {}

    return unless @hasEventListeners( event.type )

    event.dispatcher = this

    for proxy in @proxies[ event.type ]
      proxy( event )
 
  ###
  Returns true if there are any methods registered for specified `Event` type.
  @param eventType [String] `Event` type
  ###
  hasEventListeners: (eventType) ->
    unless @proxies
      @proxies = {}

    @proxies[ eventType ] and @proxies[ eventType ].length > 0
 
  ###
  Removes all event listeners.
  ###
  removeAllEventListeners: ->
    @proxies = {}