// Generated by CoffeeScript 1.6.2
/*
Base class for objects supporting event dispatching.

@author [Brian Vaughn](http://www.briandavidvaughn.com), [Adrian Wiecek](http://adrianwiecek.com/2012/02/24/coffeescript-eventdispatcher/)
*/

var CompositeTask, Event, EventDispatcher, Proxy, Task, TaskEvent, TaskWithClosure, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventDispatcher = (function() {
  /*
  @private
  */
  function EventDispatcher() {
    this.proxies = {};
  }

  /*
  Registers method for specified eventType.
  @param eventType [String] Event type / name
  @param method [Function] Function accepting 1 parameter of type `Event`
  @param thisScope [Object] The *this* scope to apply to the callback method
  */


  EventDispatcher.prototype.addEventListener = function(eventType, method, thisScope) {
    var newProxy, proxy, _i, _len, _ref;

    if (!this.proxies) {
      this.proxies = {};
    }
    if (!this.proxies[eventType]) {
      this.proxies[eventType] = [];
    }
    newProxy = new Proxy(method, thisScope);
    _ref = this.proxies;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      proxy = _ref[_i];
      if (proxy.equals(newProxy)) {
        return;
      }
    }
    return this.proxies[eventType].push(newProxy);
  };

  /*
  Removes registered method for specified eventType.
  @param eventType [String] Event type / name
  @param method [Function] Function
  @param thisScope [Object] The *this* scope to apply to the callback method
  */


  EventDispatcher.prototype.removeEventListener = function(eventType, method, thisScope) {
    var index, newProxy, proxy, _i, _len, _ref, _results;

    if (!this.proxies) {
      this.proxies = {};
    }
    if (!this.hasEventListeners(eventType)) {
      return;
    }
    newProxy = new Proxy(method, thisScope);
    _ref = this.proxies;
    _results = [];
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      proxy = _ref[index];
      if (proxy.equals(newProxy)) {
        this.proxies.splice(index, 1);
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  /*
  Invokes all registered methods for specified event.
  @param event [Event] Event to dispatch
  */


  EventDispatcher.prototype.dispatchEvent = function(event) {
    var proxy, _i, _len, _ref, _results;

    if (!this.proxies) {
      this.proxies = {};
    }
    if (!this.hasEventListeners(event.eventType)) {
      return;
    }
    event.target = this;
    _ref = this.proxies[event.eventType];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      proxy = _ref[_i];
      _results.push(proxy(event));
    }
    return _results;
  };

  /*
  Returns true if there are any methods registered for specified eventType.
  @param eventType [String] Event type / name
  */


  EventDispatcher.prototype.hasEventListeners = function(eventType) {
    if (!this.proxies) {
      this.proxies = {};
    }
    return this.proxies[eventType] && this.proxies[eventType].length > 0;
  };

  /*
  Removes all registered methods.
  */


  EventDispatcher.prototype.removeAllEventListeners = function() {
    return this.proxies = {};
  };

  return EventDispatcher;

})();

/*
A Task is any operation that can be started and completed.
A Task may be a self-contained operation or it may be a composite of many such other Tasks.

To create a usable Task, extend this class and override the **customRun()**, **customReset()**, and **customInterrupt()** methods.
Your Task should call taskComplete() or taskError() upon completion.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
*/


Task = (function(_super) {
  var get, set,
    _this = this;

  __extends(Task, _super);

  get = function(props) {
    var getter, name, _results;

    _results = [];
    for (name in props) {
      getter = props[name];
      _results.push(Task.prototype.__defineGetter__(name, getter));
    }
    return _results;
  };

  set = function(props) {
    var name, setter, _results;

    _results = [];
    for (name in props) {
      setter = props[name];
      _results.push(Task.prototype.__defineSetter__(name, setter));
    }
    return _results;
  };

  Task.uid = 0;

  /*
  Constructor
  @param taskIdentifier [String] Optional human-readable label for Task-instance; can be useful for debugging or logging purposes
  */


  function Task(_taskIdentifier) {
    this._taskIdentifier = _taskIdentifier;
    this._id = ++Task.uid;
    this._data = null;
    this._message = null;
    this._interruptingTask = null;
    this._synchronous = false;
    this._completed = false;
    this._errored = false;
    this._interrupted = false;
    this._running = false;
    this._numTimesCompleted = 0;
    this._numTimesErrored = 0;
    this._numTimesInterrupted = 0;
    this._numTimesReset = 0;
    this._numTimesStarted = 0;
    this._completeHandlers = [];
    this._errorHandlers = [];
    this._finalHandlers = [];
    this._interruptHandlers = [];
    this._startHandlers = [];
  }

  /*
  Resets the task to it's pre-run state.
  This allows it to be re-run.
  This method can only be called on non-running tasks.
  @return [Task] A reference to the current Task
  */


  Task.prototype.reset = function() {
    if (this.running) {
      return;
    }
    if (this.numTimesStarted === 0) {
      return;
    }
    this._numTimesReset++;
    this._completed = false;
    this._errored = false;
    this._interrupted = false;
    this._numTimesCompleted = 0;
    this._numTimesErrored = 0;
    this._numTimesInterrupted = 0;
    this._numTimesStarted = 0;
    this.customReset();
    return this;
  };

  /*
  Starts a task.
  This method may be used to retry an errored Task or to resume an interrupted Task.
  @return [Task] A reference to the current Task
  */


  Task.prototype.run = function() {
    var startHandler, _i, _len, _ref;

    if (this._running) {
      return;
    }
    this._running = true;
    this._numTimesStarted++;
    this._interrupted = false;
    this._running = true;
    _ref = this._startHandlers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      startHandler = _ref[_i];
      this.executeTaskStateChangeProxy(startHandler);
    }
    this.customRun();
    return this;
  };

  /*
  -----------------------------------------------------------------
  Subclasses should override the following methods
  -----------------------------------------------------------------
  */


  /*
  Override this method to give your Task functionality.
  @throw Error if not implemented
  */


  Task.prototype.customRun = function() {
    throw "Tasks must implement customRun() method";
  };

  /*
  Sub-classes should override this method to implement interruption behavior (removing event listeners, pausing objects, etc.).
  @throw Error if not implemented
  */


  Task.prototype.customInterrupt = function() {
    throw "Tasks must implement customInterrupt() method";
  };

  /*
  Override this method to perform any custom reset operations.
  @throw [Error] Error if not implemented
  */


  Task.prototype.customReset = function() {
    throw "Tasks must implement customReset() method";
  };

  /*
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  */


  get({
    completed: function() {
      return this._completed;
    }
  });

  get({
    data: function() {
      return this._data;
    }
  });

  get({
    errored: function() {
      return this._errored;
    }
  });

  get({
    id: function() {
      return this._id;
    }
  });

  get({
    interrupted: function() {
      return this._interrupted;
    }
  });

  get({
    interruptingTask: function() {
      return this._interruptingTask;
    }
  });

  get({
    message: function() {
      return this._message;
    }
  });

  get({
    numInternalOperations: function() {
      return 1;
    }
  });

  get({
    numInternalOperationsCompleted: function() {
      var _ref;

      return (_ref = this.completed) != null ? _ref : {
        1: 0
      };
    }
  });

  get({
    numInternalOperationsPending: function() {
      return this.numInternalOperations - this.numInternalOperationsCompleted;
    }
  });

  get({
    numTimesCompleted: function() {
      return this._numTimesCompleted;
    }
  });

  get({
    numTimesErrored: function() {
      return this._numTimesErrored;
    }
  });

  get({
    numTimesInterrupted: function() {
      return this._numTimesInterrupted;
    }
  });

  get({
    numTimesReset: function() {
      return this._numTimesReset;
    }
  });

  get({
    numTimesStarted: function() {
      return this._numTimesStarted;
    }
  });

  get({
    running: function() {
      return this._running;
    }
  });

  get({
    synchronous: function() {
      return this._synchronous;
    }
  });

  get({
    taskIdentifier: function() {
      return this._taskIdentifier;
    }
  });

  set({
    taskIdentifier: function(_taskIdentifier) {
      this._taskIdentifier = _taskIdentifier;
    }
  });

  /*
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  */


  /*
  The provided function will be invoked only upon successful completion of the task.
  Function should accept 1 parameter of type <Task>
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.withCompleteHandler = function(methodOrProxy) {
    this.addProxyToSet(this._completeHandlers, methodOrProxy);
    return this;
  };

  /*
  Removes a registered Task-completed handler.
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.removeCompleteHandler = function(methodOrProxy) {
    this.removeProxyFromSet(this._completeHandlers, methodOrProxy);
    return this;
  };

  /*
  The provided function will be invoked only upon failure of the task.
  Function should accept 1 parameter of type <Task>
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.withErrorHandler = function(methodOrProxy) {
    this.addProxyToSet(this._errorHandlers, methodOrProxy);
    return this;
  };

  /*
  Removes a registered Task-errorred handler.
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.removeErrorHandler = function(methodOrProxy) {
    this.removeProxyFromSet(this._errorHandlers, methodOrProxy);
    return this;
  };

  /*
  This handler is invoked upon either success or failure of the Task.
  Function should accept 1 parameter of type <Task>
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.withFinalHandler = function(methodOrProxy) {
    this.addProxyToSet(this._finalHandlers, methodOrProxy);
    return this;
  };

  /*
  Removes a registered final handler.
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.removeFinalHandler = function(methodOrProxy) {
    this.removeProxyFromSet(this._finalHandlers, methodOrProxy);
    return this;
  };

  /*
  The provided function will be invoked only upon interruption of the Task.
  Function should accept 1 parameter of type <Task>
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.withInterruptHandler = function(methodOrProxy) {
    this.addProxyToSet(this._interruptHandlers, methodOrProxy);
    return this;
  };

  /*
  Removes a registered Task-interrupted handler.
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.removeInterruptHandler = function(methodOrProxy) {
    this.removeProxyFromSet(this._interruptHandlers, methodOrProxy);
    return this;
  };

  /*
  The provided function will be invoked each time the task is started (or re-started).
  Function should accept 1 parameter of type <Task>
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.withStartHandler = function(methodOrProxy) {
    this.addProxyToSet(this._startHandlers, methodOrProxy);
    return this;
  };

  /*
  Removes a registered Task-started handler.
  @param methodOrProxy [Proxy]
    Function or Proxy;
    If a function is provided it will be converted to a Proxy with a "this" scope of this Task.
  */


  Task.prototype.removeStartHandler = function(methodOrProxy) {
    this.removeProxyFromSet(this._startHandlers, methodOrProxy);
    return this;
  };

  /*
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  */


  /*
  Adds the specified function (or Proxy) to the specified Array
  @private
  */


  Task.prototype.addProxyToSet = function(proxies, methodOrProxyToAdd) {
    var proxy, proxyToAdd, _i, _len;

    if (methodOrProxyToAdd instanceof Proxy) {
      proxyToAdd = methodOrProxyToAdd;
    } else {
      proxyToAdd = new Proxy(methodOrProxyToAdd, this);
    }
    for (_i = 0, _len = proxies.length; _i < _len; _i++) {
      proxy = proxies[_i];
      if (proxy.equals(proxyToAdd)) {
        return;
      }
    }
    return proxies.push(proxyToAdd);
  };

  /*
  Executes a function or a Proxy (with inner function)
  @private
  */


  Task.prototype.executeTaskStateChangeProxy = function(proxy) {
    return proxy(this);
  };

  /*
  Removes the specified function (or Proxy) from the specified Array
  @private
  */


  Task.prototype.removeProxyFromSet = function(proxies, methodOrProxyToRemove) {
    var index, proxy, proxyToRemove, _i, _len, _results;

    if (methodOrProxyToRemove instanceof Proxy) {
      proxyToRemove = methodOrProxyToRemove;
    } else {
      proxyToRemove = new Proxy(proxyToRemove, this);
    }
    _results = [];
    for (index = _i = 0, _len = proxies.length; _i < _len; index = ++_i) {
      proxy = proxies[index];
      if (proxy.equals(proxyToRemove)) {
        proxies.splice(index, 1);
        break;
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  /*
  -----------------------------------------------------------------
  State change helper methods
  -----------------------------------------------------------------
  */


  Task.prototype.taskComplete = function(message, data) {
    var completeHandler, finalHandler, _i, _j, _len, _len1, _ref, _ref1;

    if (message == null) {
      message = "";
    }
    if (data == null) {
      data = null;
    }
    if (!this._running) {
      return;
    }
    this._data = data;
    this._message = message;
    this._completed = true;
    this._errored = false;
    this._interrupted = true;
    this._running = false;
    this._numTimesCompleted++;
    _ref = this._completeHandlers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      completeHandler = _ref[_i];
      this.executeTaskStateChangeProxy(completeHandler);
    }
    this.dispatchEvent(new TaskEvent(TaskEvent.COMPLETE));
    _ref1 = this._finalHandlers;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      finalHandler = _ref1[_j];
      this.executeTaskStateChangeProxy(finalHandler);
    }
    return this.dispatchEvent(new TaskEvent(TaskEvent.FINAL));
  };

  Task.prototype.taskError = function(message, data) {
    var errorHandler, finalHandler, _i, _j, _len, _len1, _ref, _ref1;

    if (message == null) {
      message = "";
    }
    if (data == null) {
      data = null;
    }
    if (!this._running) {
      return;
    }
    this._data = data;
    this._message = message;
    this._completed = false;
    this._errored = true;
    this._interrupted = true;
    this._running = false;
    this._numTimesErrored++;
    _ref = this._errorHandlers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      errorHandler = _ref[_i];
      this.executeTaskStateChangeProxy(errorHandler);
    }
    this.dispatchEvent(new TaskEvent(TaskEvent.ERROR));
    _ref1 = this._finalHandlers;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      finalHandler = _ref1[_j];
      this.executeTaskStateChangeProxy(finalHandler);
    }
    return this.dispatchEvent(new TaskEvent(TaskEvent.FINAL));
  };

  return Task;

}).call(this, EventDispatcher);

/*
Task that invokes a specified function upon execution.
The function invoked will retain the scope of where it was defined, allowing for easy access to other class/method variables.

This type of Task can be asynchronous.
It will not complete (or error) until specifically instructed to do so.
This instruction should be triggered as a result of the custom function it executes.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
*/


TaskWithClosure = (function(_super) {
  __extends(TaskWithClosure, _super);

  /*
  Constructor
  @param customRunFunction [Function] Function to be executed when this Task is run
  @param autoCompleteAfterRunningFunction [Boolean] If TRUE this Task will complete after running custom function (unless custom function called "errorTask")
  @param taskIdentifier [String] Optional human-readable label for Task-instance; can be useful for debugging or logging purposes
  */


  function TaskWithClosure(customRunFunction, _autoCompleteAfterRunningFunction, _taskIdentifier) {
    this.customRunFunction = customRunFunction;
    this._autoCompleteAfterRunningFunction = _autoCompleteAfterRunningFunction != null ? _autoCompleteAfterRunningFunction : false;
    this._taskIdentifier = _taskIdentifier;
    TaskWithClosure.__super__.constructor.call(this, this._taskIdentifier);
  }

  TaskWithClosure.prototype.customRun = function() {
    this.customRunFunction();
    if (this._autoCompleteAfterRunningFunction) {
      return this.taskComplete();
    }
  };

  return TaskWithClosure;

})(Task);

/*
# Base class for events. #

@author [Brian Vaughn](http://www.briandavidvaughn.com)
*/


Event = (function() {
  var get, set,
    _this = this;

  get = function(props) {
    var getter, name, _results;

    _results = [];
    for (name in props) {
      getter = props[name];
      _results.push(Event.prototype.__defineGetter__(name, getter));
    }
    return _results;
  };

  set = function(props) {
    var name, setter, _results;

    _results = [];
    for (name in props) {
      setter = props[name];
      _results.push(Event.prototype.__defineSetter__(name, setter));
    }
    return _results;
  };

  /*
  This is the constructor.
  @param [String] event type/name
  @param [Object] optional event data
  */


  function Event(eventType, data) {
    this.eventType = eventType;
    this.data = data;
  }

  get({
    target: function() {
      return this._target;
    }
  });

  set({
    target: function(_target) {
      this._target = _target;
    }
  });

  return Event;

}).call(this);

/*
Dispatched by a Task to indicated a change in state.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
*/


TaskEvent = (function(_super) {
  var get, set,
    _this = this;

  __extends(TaskEvent, _super);

  function TaskEvent() {
    _ref = TaskEvent.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  get = function(props) {
    var getter, name, _results;

    _results = [];
    for (name in props) {
      getter = props[name];
      _results.push(TaskEvent.prototype.__defineGetter__(name, getter));
    }
    return _results;
  };

  set = function(props) {
    var name, setter, _results;

    _results = [];
    for (name in props) {
      setter = props[name];
      _results.push(TaskEvent.prototype.__defineSetter__(name, setter));
    }
    return _results;
  };

  /*
  A task has completed successfully.
  */


  TaskEvent.COMPLETE = "TaskEvent.COMPLETE";

  /*
  A task has failed.
  */


  TaskEvent.ERROR = "TaskEvent.ERROR";

  /*
  A task has either completed or failed.
  */


  TaskEvent.FINAL = "TaskEvent.FINAL";

  /*
  A task has started running.
  */


  TaskEvent.STARTED = "TaskEvent.STARTED";

  /*
  A Task has been interrupted.
  */


  TaskEvent.INTERRUPTED = "TaskEvent.INTERRUPTED";

  get({
    task: function() {
      return this.target;
    }
  });

  return TaskEvent;

}).call(this, Event);

/*
Encapsulates a function and its scope, enabling the function to be later executed within the desired scope.

@method #equals(key, value)
  Compares the current function and scope to those contained in another Proxy.
  @param otherProxy [Proxy] Proxy to compare this one to
  @return [Boolean] Whether or not the two Proxy objects point to the same function and scope

@author [Brian Vaughn](http://www.briandavidvaughn.com)
*/


Proxy = (function() {
  var get, set,
    _this = this;

  get = function(props) {
    var getter, name, _results;

    _results = [];
    for (name in props) {
      getter = props[name];
      _results.push(Proxy.prototype.__defineGetter__(name, getter));
    }
    return _results;
  };

  set = function(props) {
    var name, setter, _results;

    _results = [];
    for (name in props) {
      setter = props[name];
      _results.push(Proxy.prototype.__defineSetter__(name, setter));
    }
    return _results;
  };

  /*
  Constructor.
  @param closure [Function] A function
  @param thisScope [Object] Optional "this" scope to apply to the function
  */


  function Proxy(closure, thisScope) {
    var InnerProxy, that;

    this.closure = closure;
    this.thisScope = thisScope;
    that = this;
    /*
    @private
    */

    InnerProxy = (function() {
      function InnerProxy() {
        this.closure = that.closure;
        this.thisScope = that.thisScope;
        return this.closure.apply(this.thisScope, arguments);
      }

      return InnerProxy;

    })();
    InnerProxy.closure = this.closure;
    InnerProxy.thisScope = this.thisScope;
    InnerProxy.equals = function( otherProxy ) {
        return that.thisScope == otherProxy.thisScope &&
               that.closure   == otherProxy.closure;
      };
    return InnerProxy;
  }

  get({
    closure: function() {
      return this._closure;
    }
  });

  set({
    closure: function(_closure) {
      this._closure = _closure;
    }
  });

  get({
    thisScope: function() {
      return this._thisScope;
    }
  });

  set({
    thisScope: function(_thisScope) {
      this._thisScope = _thisScope;
    }
  });

  return Proxy;

}).call(this);

/*
Wraps a set of ITasks and executes them in parallel or serial, as specified by a boolean constructor arg.

@author [Brian Vaughn](http://www.briandavidvaughn.com)
*/


CompositeTask = (function(_super) {
  var get, set,
    _this = this;

  __extends(CompositeTask, _super);

  get = function(props) {
    var getter, name, _results;

    _results = [];
    for (name in props) {
      getter = props[name];
      _results.push(CompositeTask.prototype.__defineGetter__(name, getter));
    }
    return _results;
  };

  set = function(props) {
    var name, setter, _results;

    _results = [];
    for (name in props) {
      setter = props[name];
      _results.push(CompositeTask.prototype.__defineSetter__(name, setter));
    }
    return _results;
  };

  /*
  Constructor.
  @param taskQueue [Array<Task>] Set of Tasks and/or functions to be executed.
  @param executeTaskInParallel [Boolean] Execute all Tasks at the same time; if this value is FALSE Tasks will be executed in serial.
  @param taskIdentifier [String] Optional human-readable label for Task-instance; can be useful for debugging or logging purposes.
  */


  function CompositeTask(_taskQueue, _executeTaskInParallel, _taskIdentifier) {
    this._taskQueue = _taskQueue != null ? _taskQueue : [];
    this._executeTaskInParallel = _executeTaskInParallel != null ? _executeTaskInParallel : true;
    this._taskIdentifier = _taskIdentifier;
    CompositeTask.__super__.constructor.call(this, this._taskIdentifier);
    this._addTasksBeforeRunInvoked = false;
    this._erroredTasks = [];
    this._flushTaskQueueLock = false;
    this._taskQueueIndex = 0;
  }

  CompositeTask.prototype.customRun = function() {
    var task, _i, _j, _len, _len1, _ref1, _ref2, _results;

    if (!this._addTasksBeforeRunInvoked) {
      this.addTasksBeforeRun();
      this._addTasksBeforeRunInvoked = true;
    }
    if (this._taskQueue.length === 0 || this.allTasksAreCompleted) {
      this.taskComplete();
      return;
    }
    this._erroredTasks = [];
    _ref1 = this._taskQueue;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      task = _ref1[_i];
      this.addTaskEventListeners(task);
    }
    if (this._executeTaskInParallel) {
      _ref2 = this._taskQueue;
      _results = [];
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        task = _ref2[_j];
        _results.push(task.run());
      }
      return _results;
    } else {
      return this.currentSerialTask.run();
    }
  };

  /*
  -----------------------------------------------------------------
  Getters / setters
  -----------------------------------------------------------------
  */


  get({
    allTasksAreCompleted: function() {
      var task, _i, _len, _ref1;

      _ref1 = this._taskQueue;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        task = _ref1[_i];
        if (!task.completed) {
          return false;
        }
      }
      return true;
    }
  });

  get({
    currentSerialTask: function() {
      if (this._taskQueue.length > this._taskQueueIndex) {
        return this._taskQueue[this._taskQueueIndex];
      } else {
        return null;
      }
    }
  });

  get({
    errorMessages: function() {
      var returnArray, task, _i, _len, _ref1;

      returnArray = [];
      _ref1 = this._erroredTasks;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        task = _ref1[_i];
        returnArray.push(task.message);
      }
      return returnArray;
    }
  });

  get({
    errorDatas: function() {
      var returnArray, task, _i, _len, _ref1;

      returnArray = [];
      _ref1 = this._erroredTasks;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        task = _ref1[_i];
        returnArray.push(task.data);
      }
      return returnArray;
    }
  });

  get({
    erroredTasks: function() {
      return this._erroredTasks;
    }
  });

  /*
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  */


  CompositeTask.prototype.addTaskEventListeners = function(task) {
    task.withCompleteHandler(new Proxy(this._individualTaskCompleted, this));
    task.withErrorHandler(new Proxy(this._individualTaskCompleteded, this));
    return task.withStartHandler(new Proxy(this._individualTaskStarted, this));
  };

  CompositeTask.prototype.checkForTaskCompletion = function() {
    if (this._flushTaskQueueLock) {
      return;
    }
    if (this._taskQueue.length >= this._taskQueueIndex + 1 + this._erroredTasks.length) {
      return;
    }
    if (this._erroredTasks.length > 0) {
      return this.taskError(errorMessages, errorDatas);
    } else {
      return this.taskComplete();
    }
  };

  CompositeTask.prototype.handleTaskCompletedOrRemoved = function(task) {
    this.removeTaskEventListeners(task);
    if (task.completed) {
      this.individualTaskComplete(task);
    }
    this._taskQueueIndex++;
    if (!this.running) {
      return;
    }
    if (this._executeTaskInParallel) {
      return this.checkForTaskCompletion();
    } else {
      if (this.currentSerialTask) {
        return this.currentSerialTask.run();
      } else {
        return this.checkForTaskCompletion();
      }
    }
  };

  CompositeTask.prototype.removeTaskEventListeners = function(task) {
    task.removeCompleteHandler(new Proxy(this._individualTaskCompleted, this));
    task.removeErrorHandler(new Proxy(this._individualTaskCompleteded, this));
    return task.removeStartHandler(new Proxy(this._individualTaskStarted, this));
  };

  /*
  Individual Task event handlers
  */


  CompositeTask.prototype._individualTaskCompleted = function(task) {
    return this.handleTaskCompletedOrRemoved(task);
  };

  CompositeTask.prototype._individualTaskErrored = function(task) {};

  CompositeTask.prototype._individualTaskStarted = function(task) {};

  /*
  Sub-classes may override the following methods
  */


  CompositeTask.prototype.addTasksBeforeRun = function() {};

  CompositeTask.prototype.individualTaskComplete = function() {};

  CompositeTask.prototype.individualTaskStarted = function() {};

  return CompositeTask;

}).call(this, Task);
