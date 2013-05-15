// Generated by CoffeeScript 1.6.2
var CompositeTask, Event, EventDispatcher, Task, TaskWithClosure,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventDispatcher = (function() {
  function EventDispatcher() {}

  EventDispatcher.prototype.callbacks = {};

  EventDispatcher.prototype.addListener = function(eventType, callback) {
    if (!this.callbacks[eventType]) {
      this.callbacks[eventType] = [];
    }
    if (this.callbacks[eventType].indexOf(callback) < 0) {
      return this.callbacks[eventType].push(callback);
    }
  };

  EventDispatcher.prototype.removeListener = function(eventType, callback) {
    var index;

    if (!this.hasListeners(eventType)) {
      return;
    }
    index = this.callbacks[eventType].indexOf(callback);
    if (index === -1) {
      return;
    }
    this.callbacks[eventType].splice(index, 1);
  };

  EventDispatcher.prototype.dispatch = function(event) {
    var callback, _i, _len, _ref;

    if (!this.hasListeners(event.eventType)) {
      return;
    }
    _ref = this.callbacks[event.eventType];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      callback = _ref[_i];
      callback(event);
    }
  };

  EventDispatcher.prototype.hasListeners = function(eventType) {
    return this.callbacks[eventType] && this.callbacks[eventType].length > 0;
  };

  EventDispatcher.prototype.removeAllListeners = function() {
    return this.callbacks = {};
  };

  return EventDispatcher;

})();

Function.prototype.property = function(prop, desc) {
  return Object.defineProperty(this.prototype, prop, desc);
};

Task = (function(_super) {
  __extends(Task, _super);

  Task.uid = 0;

  function Task(_taskIdentifier) {
    this._taskIdentifier = _taskIdentifier;
    this._id = ++Task.uid;
    this._data = null;
    this._message = null;
    this._completed = false;
    this._errored = false;
    this._interrupted = false;
    this._running = false;
    this._numTimesCompleted = 0;
    this._numTimesErrored = 0;
    this._numTimesInterrupted = 0;
    this._numTimesStarted = 0;
    this._completeHandlers = [];
    this._errorHandlers = [];
    this._finalHandlers = [];
    this._interruptHandlers = [];
    this._startHandlers = [];
  }

  /*
  Override this method to give your Task functionality.
  */


  Task.prototype.customRun = function() {};

  /*
  Starts a task.
  This method may also be used to retry/resume an errored task.
  */


  Task.prototype.run = function() {
    this._running = true;
    this.customRun();
    return this;
  };

  /*
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  */


  Task.property('id', {
    get: function() {
      return this._id;
    }
  });

  Task.property('data', {
    get: function() {
      return this._data;
    }
  });

  Task.property('message', {
    get: function() {
      return this._message;
    }
  });

  Task.property('taskIdentifier', {
    get: function() {
      return this._taskIdentifier;
    }
  });

  Task.property('completed', {
    get: function() {
      return this._completed;
    }
  });

  Task.property('errored', {
    get: function() {
      return this._errored;
    }
  });

  Task.property('interrupted', {
    get: function() {
      return this._interrupted;
    }
  });

  Task.property('running', {
    get: function() {
      return this._running;
    }
  });

  Task.property('numTimesCompleted', {
    get: function() {
      return this._numTimesCompleted;
    }
  });

  Task.property('numTimesErrored', {
    get: function() {
      return this._numTimesErrored;
    }
  });

  Task.property('numTimesInterrupted', {
    get: function() {
      return this._numTimesInterrupted;
    }
  });

  Task.property('numTimesStarted', {
    get: function() {
      return this._numTimesStarted;
    }
  });

  /*
  -----------------------------------------------------------------
  Getter / setter methods
  -----------------------------------------------------------------
  */


  /*
  The provided function will be invoked only upon successful completion of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  */


  Task.prototype.withCompleteHandler = function(closure) {
    if (this._completeHandlers.indexOf(closure) < 0) {
      this._completeHandlers.push(closure);
    }
    return this;
  };

  Task.prototype.removeCompleteHandler = function(closure) {
    if (this._completeHandlers.indexOf(closure) >= 0) {
      return this._completeHandlers.splice(this._completeHandlers.indexOf(closure), 1);
    }
  };

  /*
  The provided function will be invoked only upon failure of the task.
  Function can accept 0 arguments or 1 argument (the current Task)
  */


  Task.prototype.withErrorHandler = function(closure) {
    if (this._errorHandlers.indexOf(closure) < 0) {
      this._errorHandlers.push(closure);
    }
    return this;
  };

  Task.prototype.removeErrorHandler = function(closure) {
    if (this._errorHandlers.indexOf(closure) >= 0) {
      return this._errorHandlers.splice(this._errorHandlers.indexOf(closure), 1);
    }
  };

  /*
  This handler is invoked upon either success or failure of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  */


  Task.prototype.withFinalHandler = function(closure) {
    if (this._finalHandlers.indexOf(closure) < 0) {
      this._finalHandlers.push(closure);
    }
    return this;
  };

  Task.prototype.removeFinalHandler = function(closure) {
    if (this._finalHandlers.indexOf(closure) >= 0) {
      return this._finalHandlers.splice(this._finalHandlers.indexOf(closure), 1);
    }
  };

  /*
  The provided function will be invoked only upon interruption of the Task.
  Function can accept 0 arguments or 1 argument (the current Task)
  */


  Task.prototype.withInterruptHandler = function(closure) {
    if (this._interruptHandlers.indexOf(closure) < 0) {
      this._interruptHandlers.push(closure);
    }
    return this;
  };

  Task.prototype.removeInterruptHandler = function(closure) {
    if (this._interruptHandlers.indexOf(closure) >= 0) {
      return this._interruptHandlers.splice(this._interruptHandlers.indexOf(closure), 1);
    }
  };

  /*
  The provided function will be invoked each time the task is started (or re-started).
  Function can accept 0 arguments or 1 argument (the current Task)
  */


  Task.prototype.withStartHandler = function(closure) {
    if (this._startHandlers.indexOf(closure) < 0) {
      this._startHandlers.push(closure);
    }
    return this;
  };

  Task.prototype.removeStartHandler = function(closure) {
    if (this._startHandlers.indexOf(closure) >= 0) {
      return this._startHandlers.splice(this._startHandlers.indexOf(closure), 1);
    }
  };

  /*
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  */


  /*
  Returns a closure with the appropriate `this` scope.
  This convenience method is useful for attaching state-change listeners.
  */


  Task.prototype.wrapper = function(closure) {
    var scope;

    scope = this;
    return function() {
      closure.apply( scope, arguments );
    };
  };

  /*
  -----------------------------------------------------------------
  State change helper methods
  -----------------------------------------------------------------
  */


  Task.prototype.taskComplete = function(message, data) {
    var completeHandler, finalHandler, _i, _j, _len, _len1, _ref, _ref1, _results;

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
      completeHandler(this);
    }
    _ref1 = this._finalHandlers;
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      finalHandler = _ref1[_j];
      _results.push(finalHandler(this));
    }
    return _results;
  };

  Task.prototype.taskError = function(message, data) {
    var errorHandler, finalHandler, _i, _j, _len, _len1, _ref, _ref1, _results;

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
      errorHandler(this);
    }
    _ref1 = this._finalHandlers;
    _results = [];
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      finalHandler = _ref1[_j];
      _results.push(finalHandler(this));
    }
    return _results;
  };

  return Task;

})(EventDispatcher);

TaskWithClosure = (function(_super) {
  __extends(TaskWithClosure, _super);

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

Event = (function() {
  function Event(eventType, data) {
    this.eventType = eventType;
    this.data = data;
  }

  return Event;

})();

CompositeTask = (function(_super) {
  __extends(CompositeTask, _super);

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
    var task, _i, _j, _len, _len1, _ref, _ref1, _results;

    if (!this._addTasksBeforeRunInvoked) {
      this.addTasksBeforeRun();
      this._addTasksBeforeRunInvoked = true;
    }
    if (this._taskQueue.length === 0 || this.allTasksAreCompleted) {
      console.log("No task or all are completed");
      this.taskComplete();
      return;
    }
    this._erroredTasks = [];
    _ref = this._taskQueue;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      task = _ref[_i];
      this.addTaskEventListeners(task);
    }
    if (this._executeTaskInParallel) {
      _ref1 = this._taskQueue;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        task = _ref1[_j];
        _results.push(task.run());
      }
      return _results;
    } else {
      return currentSerialTask.run();
    }
  };

  /*
  -----------------------------------------------------------------
  Getters / setters
  -----------------------------------------------------------------
  */


  /*
  No incomplete Tasks remain in the queue.
  */


  CompositeTask.property('allTasksAreCompleted', {
    get: function() {
      var task, _i, _len, _ref;

      _ref = this._taskQueue;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        task = _ref[_i];
        if (!task.completed) {
          return false;
        }
      }
      return true;
    }
  });

  /*
  References the Task that is currently running (if this CompositeTask has been told to execute in serial).
  */


  CompositeTask.property('currentSerialTask', {
    get: function() {
      if (this._taskQueue.length > this._taskQueueIndex) {
        return this._taskQueue[this._taskQueueIndex];
      } else {
        return null;
      }
    }
  });

  /*
  Unique error messages from all inner Tasks that failed during execution.
  This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  */


  CompositeTask.property('errorMessages', {
    get: function() {
      var returnArray, task, _i, _len, _ref;

      returnArray = [];
      _ref = this._erroredTasks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        task = _ref[_i];
        returnArray.push(task.message);
      }
      return returnArray;
    }
  });

  /*
  Error datas from all inner Tasks that failed during execution.
  This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  */


  CompositeTask.property('errorDatas', {
    get: function() {
      var returnArray, task, _i, _len, _ref;

      returnArray = [];
      _ref = this._erroredTasks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        task = _ref[_i];
        returnArray.push(task.data);
      }
      return returnArray;
    }
  });

  /*
  Tasks that errored during execution.
  This value is valid after during execution of the CompositeTask as well as upon completion (or failure).
  */


  CompositeTask.property('erroredTasks', {
    get: function() {
      return this._erroredTasks;
    }
  });

  /*
  -----------------------------------------------------------------
  Helper methods
  -----------------------------------------------------------------
  */


  CompositeTask.prototype.addTaskEventListeners = function(task) {
    task.withCompleteHandler(this.wrapper(this._individualTaskCompleted));
    task.withErrorHandler(this.wrapper(this._individualTaskCompleteded));
    return task.withStartHandler(this.wrapper(this._individualTaskStarted));
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
    if (task.isComplete) {
      individualTaskComplete(task);
    }
    this._taskQueueIndex++;
    if (!this.running) {
      return;
    }
    if (this.handleTaskCompletedOrRemoved) {
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
    task.removeCompleteHandler(this._individualTaskCompleted);
    task.removeErrorHandler(this._individualTaskCompleteded);
    return task.removeStartHandler(this._individualTaskStarted);
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

  CompositeTask.prototype.addTasksBeforeRun = function() {};

  CompositeTask.prototype.addTasksBeforeRun = function() {};

  return CompositeTask;

})(Task);
