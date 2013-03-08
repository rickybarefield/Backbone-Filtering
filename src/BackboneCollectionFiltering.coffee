socket = $.atmosphere
Backbone = this.Backbone
_ = this._


oldFilter = Backbone.Collection.prototype.filter


class BackboneFilteredCollection extends Backbone.Collection

  @uniqueContext: ->
    if @lastNumber? then @lastNumber++ else @lastNumber = 1
    return "BackboneFilteredCollection" + @lastNumber

  constructor: (@sourceCollection, @filter) ->
    super()
 
  fetch: -> console.log("no fetch, should delegate")

  #Should probably override sync alltogether

Backbone.Collection.prototype.filter = (filter) ->

  handleChange = (model) ->

    removedFrom =  for filteredCollection in @filteredCollections when _.contains(filteredCollection.models, model) and !(filteredCollection.filter(model))
      filteredCollection.remove(model)
      return filteredCollection

    addedTo = for filteredCollection in @filteredCollections when filteredCollection.filter(model)
      filteredCollection.add(model)

    if addedTo.length == 1 and removedFrom.length == 1
      then addedTo.trigger("movedTo", removedFrom[0])

  addAllMatching = (models) ->
    handleAdd(model) for model in models

  addListener = (model) ->
    model.on "change", (=> handleChange(model)), uniqueContext()

  handleAdd = (model) ->
    addListener(model)

    for filteredCollecton in @filteredCollections when filteredCollection.filter(model)
      filteredCollection.add(model)

  handleRemove = (model) ->
    filteredCollection.remove(model) for filteredCollection in @filteredCollections when _.contains(filteredCollection.models, model)

  addFilteredCollectionSupport = ->
    @hasFilteredCollectionSupport = true
    @filteredCollections = []
    @on "add", ((model) => handleAdd(model)), "FilteredCollectionContext"
    @on "remove", ((model) => handleRemove(model)), "FilteredCollectionContext"
    @on "reset", (=> addAllMatching(@models)), "FilteredCollectionContext"

  unless @hasFilteredCollectionSupport addFilteredCollectionSupport

  filteredCollection = new BackboneFilteredCollection(this, filter)
  @filteredCollections.push filteredCollection
  return filteredCollection 
