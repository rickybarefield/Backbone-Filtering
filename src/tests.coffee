class Person extends Backbone.Model

class People extends Backbone.Collection

assert = new expect.Assertion

suite 'Backbone-Filtering', ->

  allThePeople = new People
  people = {}
  
  createPersonInCollection = (name, age, collection) ->
    person = new Person
    people[name] = person
    person.set("Name", name)
    person.set("Age", age)
    collection.add(person)

  setup ->

    allThePeople = new People
    createPersonInCollection("Neil", 10, allThePeople)
    createPersonInCollection("Percy", 40, allThePeople)
    createPersonInCollection("Marion", 23, allThePeople)
    createPersonInCollection("Hilda", 63, allThePeople)

  suite 'Basic Filtering', ->

    test 'The setup is ok', ->
      expect(allThePeople.length).to.equal 4
    
    test 'Creating a filtered collection of under 30s', ->
    
      under30s = allThePeople.filter -> @.get("Age") < 30  
      expect(under30s.length).to.equal 2
      
    test 'Adding elements to the base collection', ->
    
      under30s = allThePeople.filter -> @.get("Age") < 30  
      createPersonInCollection("Smithy", 12, allThePeople)
      expect(under30s.length).to.equal 3
    
    test 'Removing elements from the base collection', ->

      under30s = allThePeople.filter -> @.get("Age") < 30
      allThePeople.remove people.Marion
      expect(under30s.length).to.equal 1
      
    test 'Updating an element in the base collection which then matches the filter', ->
    
      under30s = allThePeople.filter -> @.get("Age") < 30
      people.Percy.set("Age", 29)
      expect(under30s.length).to.equal(3)
      
  suite 'Events', ->
  
    test 'An add event is fired when a matching element is added to the base collection', ->
    
      under30s = allThePeople.filter -> @.get("Age") < 30
      addEventTriggered = false
      under30s.on "add", ->
        if addEventTriggered
          expect.fail("The event was triggered twice") 
        else
          addEventTriggered = true
      createPersonInCollection "Sheila", 2, allThePeople
      expect(addEventTriggered).to.be(true)
    
    test 'A remove event is fired when a matching element is removed from the base collection', ->
      
      under30s = allThePeople.filter -> @.get("Age") < 30
      removeEventTriggered = false
      under30s.on "remove", ->
        if removeEventTriggered
          expect.fail("The event was triggered twice") 
        else
          removeEventTriggered = true
      allThePeople.remove people.Neil
      expect(removeEventTriggered).to.be(true)

  suite 'Multiple Filters', ->
  
    test 'A collection with two filters', ->

      under30s = allThePeople.filter -> @.get("Age") < 30
      thirtyOrOvers = allThePeople.filter -> @.get("Age") >= 30
      
      expect(under30s.length).to.equal 2
      expect(thirtyOrOvers.length).to.equal 2
    
    test 'Updating an element so it moves from one filtered collection to the other', ->
    
      under30s = allThePeople.filter -> @.get("Age") < 30
      thirtyOrOvers = allThePeople.filter -> @.get("Age") >= 30

      people.Neil.set("Age", 32)
      expect(under30s.length).to.equal 1
      expect(thirtyOrOvers.length).to.equal 3
      
      #TODO - Test reset and move event
          