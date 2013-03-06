socket = $.atmosphere
Backbone = this.Backbone
_ = this._


oldFilter = Backbone.Collection.prototype.filter


class BackboneFilteredCollection extends Backbone.Collection

  @uniqueContext: ->
    if @lastNumber? then @lastNumber++ else @lastNumber = 1
    return "BackboneFilteredCollection" + @lastNumber

  constructor: (@sourceCollection, @filter, @context = BackboneFilteredCollection.uniqueContext()) ->
    super()
    @addAllMatching(@sourceCollection.models)
    @sourceCollection.on "add", ((model) => @handleAdd(model)), @context
    @sourceCollection.on "reset", (=> @handleReset(@sourceCollection.models)), @context
  
  handleAdd: (model) ->
    @addListener(model)
    if(@filter(model)) then @originalAdd(model)
  
  addListener: (model) ->
    model.on "change", ((model) => @handleChange(model)), @context

  handleChange: (model) ->
    if _.contains(@models, model)
      if !(@filter(model))
        @remove(model)
    else
      if @filter(model)
        @originalAdd(model)
  
  handleReset: (newModels) ->
    @removeListener(@models)
    @addAllMatching(newModels)
  
  addAllMatching: (models) ->
  
    @handleAdd(model) for model in models

  originalAdd: ->
    BackboneFilteredCollection.__super__.add.apply(this, arguments)

  add: ->
    @sourceCollection.add.apply(this, arguments)
  
  fetch: -> console.log("no fetch, should delegate")

Backbone.Collection.prototype.filter = (filter) ->
  return new BackboneFilteredCollection(this, filter) 
