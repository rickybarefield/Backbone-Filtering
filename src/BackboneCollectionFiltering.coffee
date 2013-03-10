socket = $.atmosphere
Backbone = this.Backbone
_ = this._

oldFilter = Backbone.Collection.prototype.filter

lastNumber = 0

aUniqueNumber = ->
  lastNumber++
  return @lastNumber

class BackboneFilteredCollection extends Backbone.Collection

  constructor: (@sourceCollection, @filter) ->
    super()
 
  fetch: -> console.log("no fetch, should delegate")

  #Should probably override sync alltogether

Backbone.Collection.prototype.filter = (filter) ->

  handleChange = (c, model) ->

    removedFrom = for filteredCollection in c.filteredCollections when _.contains(filteredCollection.models, model) and !(filteredCollection.filter.call(model, model))
      filteredCollection.remove(model)

    addedTo = for filteredCollection in c.filteredCollections when filteredCollection.filter.call(model, model)
      filteredCollection.add(model)

    ###
    if (addedTo.length == 1) and (removedFrom.length == 1)
      addedTo.trigger("movedTo", removedFrom[0])
    ###
    
  addAllMatching = (collection) ->
    handleAdd(model) for model in collection.models

  addListener = (collection, model) ->
    model.on "change", (=> handleChange(collection, model)), "BackboneCollectionFiltering" + aUniqueNumber()

  handleAdd = (collection, model) ->
    addListener(collection, model)

    filteredCollection.add(model) for filteredCollection in collection.filteredCollections when filteredCollection.filter.call(model, model)

  handleRemove = (collection, model) ->
    filteredCollection.remove(model) for filteredCollection in collection.filteredCollections when _.contains(filteredCollection.models, model)

  addFilteredCollectionSupport = (collection) =>
    collection.hasFilteredCollectionSupport = true
    collection.filteredCollections = []
    addListener(collection, model) for model in @models
    collection.on "add", ((model) => handleAdd(collection, model)), "FilteredCollectionContext"
    collection.on "remove", ((model) => handleRemove(collection, model)), "FilteredCollectionContext"
    collection.on "reset", (=> addAllMatching(collection)), "FilteredCollectionContext"
  
  addFilteredCollectionSupport(@) unless @hasFilteredCollectionSupport

  filteredCollection = new BackboneFilteredCollection(this, filter)
  @filteredCollections.push filteredCollection
  filteredCollection.add(model) for model in @models when filter.call(model, model)
  return filteredCollection 
