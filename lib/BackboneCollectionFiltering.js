// Generated by CoffeeScript 1.4.0
(function() {
  var Backbone, BackboneFilteredCollection, aUniqueNumber, lastNumber, oldFilter, socket, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  socket = $.atmosphere;

  Backbone = this.Backbone;

  _ = this._;

  oldFilter = Backbone.Collection.prototype.filter;

  lastNumber = 0;

  aUniqueNumber = function() {
    lastNumber++;
    return this.lastNumber;
  };

  BackboneFilteredCollection = (function(_super) {

    __extends(BackboneFilteredCollection, _super);

    function BackboneFilteredCollection(sourceCollection, filter) {
      this.sourceCollection = sourceCollection;
      this.filter = filter;
      BackboneFilteredCollection.__super__.constructor.call(this);
    }

    BackboneFilteredCollection.prototype.fetch = function() {
      return console.log("no fetch, should delegate");
    };

    return BackboneFilteredCollection;

  })(Backbone.Collection);

  Backbone.Collection.prototype.filter = function(filter) {
    var addAllMatching, addFilteredCollectionSupport, addListener, filteredCollection, handleAdd, handleChange, handleRemove, model, _i, _len, _ref,
      _this = this;
    handleChange = function(c, model) {
      var addedTo, filteredCollection, removedFrom;
      removedFrom = (function() {
        var _i, _len, _ref, _results;
        _ref = c.filteredCollections;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          filteredCollection = _ref[_i];
          if (_.contains(filteredCollection.models, model) && !(filteredCollection.filter.call(model, model))) {
            _results.push(filteredCollection.remove(model));
          }
        }
        return _results;
      })();
      return addedTo = (function() {
        var _i, _len, _ref, _results;
        _ref = c.filteredCollections;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          filteredCollection = _ref[_i];
          if (filteredCollection.filter.call(model, model)) {
            _results.push(filteredCollection.add(model));
          }
        }
        return _results;
      })();
      /*
          if (addedTo.length == 1) and (removedFrom.length == 1)
            addedTo.trigger("movedTo", removedFrom[0])
      */

    };
    addAllMatching = function(collection) {
      var model, _i, _len, _ref, _results;
      _ref = collection.models;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        _results.push(handleAdd(model));
      }
      return _results;
    };
    addListener = function(collection, model) {
      var _this = this;
      return model.on("change", (function() {
        return handleChange(collection, model);
      }), "BackboneCollectionFiltering" + aUniqueNumber());
    };
    handleAdd = function(collection, model) {
      var filteredCollection, _i, _len, _ref, _results;
      addListener(collection, model);
      _ref = collection.filteredCollections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filteredCollection = _ref[_i];
        if (filteredCollection.filter.call(model, model)) {
          _results.push(filteredCollection.add(model));
        }
      }
      return _results;
    };
    handleRemove = function(collection, model) {
      var filteredCollection, _i, _len, _ref, _results;
      _ref = collection.filteredCollections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        filteredCollection = _ref[_i];
        if (_.contains(filteredCollection.models, model)) {
          _results.push(filteredCollection.remove(model));
        }
      }
      return _results;
    };
    addFilteredCollectionSupport = function(collection) {
      var model, _i, _len, _ref;
      collection.hasFilteredCollectionSupport = true;
      collection.filteredCollections = [];
      _ref = _this.models;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        model = _ref[_i];
        addListener(collection, model);
      }
      collection.on("add", (function(model) {
        return handleAdd(collection, model);
      }), "FilteredCollectionContext");
      collection.on("remove", (function(model) {
        return handleRemove(collection, model);
      }), "FilteredCollectionContext");
      return collection.on("reset", (function() {
        return addAllMatching(collection);
      }), "FilteredCollectionContext");
    };
    if (!this.hasFilteredCollectionSupport) {
      addFilteredCollectionSupport(this);
    }
    filteredCollection = new BackboneFilteredCollection(this, filter);
    this.filteredCollections.push(filteredCollection);
    _ref = this.models;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      model = _ref[_i];
      if (filter.call(model, model)) {
        filteredCollection.add(model);
      }
    }
    return filteredCollection;
  };

}).call(this);
