# http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/
#Base class for objects supporting event dispatching.
class EventDispatcher
  callbacks: {}
 
  #Registers callback for specified eventType.
  #@param eventType of type String
  #@param callback of type Function,
  #should have one argument of type Event
  addListener: (eventType, callback) ->
    if not @callbacks[eventType]
      @callbacks[eventType] = []
    
    if @callbacks[eventType].indexOf(callback) < 0
      @callbacks[eventType].push(callback)
  
  #Removes registered callback for specified eventType.
  #@param eventType of type String
  #@param callback of type Function
  removeListener: (eventType, callback) ->
    return unless this.hasListeners(eventType)
    index = @callbacks[eventType].indexOf(callback)
    return if index == -1
    @callbacks[eventType].splice(index, 1);
    return
 
  #Invokes all registered callbacks for specified event.
  #@param event of type Event
  dispatch: (event) ->
    return unless this.hasListeners(event.eventType)
    callback(event) for callback in @callbacks[event.eventType]
    return
 
  #Returns true if there are any callbacks
  #registered for specified eventType.
  #@param eventType of type String
  hasListeners: (eventType) ->
    @callbacks[eventType] and @callbacks[eventType].length > 0
 
  #Removes all registered callbacks.
  removeAllListeners: ->
    @callbacks = {}