expect = require('chai').expect
sinon = require 'sinon'


Cache = require("../")

instance = null
diposeFunc = null


describe 'node expiration cache', ->
  
  describe 'Basics', ->
    it 'should instanciate a simple cache', ->
      instance = new Cache()
      expect(instance).to.exist

    it 'should add an item', ->
      ret = instance.set '1', {prop: true}
      expect(ret).to.be.true

    it 'should confirm existing key', ->
      expect(instance.has('1')).to.be.true

    it 'should confirm non existing key', ->
      expect(instance.has('test')).to.be.false

    it 'should get an item', ->
      item = instance.get '1'
      expect(item).to.exist
      expect(item).to.have.property('prop', true)

    it 'should NOT get a fake item', ->
      item = instance.get 'test'
      expect(item).to.not.exist

    it 'should peek an item', ->
      item = instance.peek '1'
      expect(item).to.exist
      expect(item).to.have.property('prop', true)
    
    it 'should NOT peek a fake item', ->
      item = instance.peek 'test'
      expect(item).to.not.exist
    
    it 'should get mulitple items', ->
      instance.set '2', {prop: false}
      items = instance.mget ['1', '2']
      expect(items).to.exist
      expect(items).to.have.keys('1', '2')
      expect(items['1']).to.have.property('prop', true)
      expect(items['2']).to.have.property('prop', false)

    it 'should get multiple fake items', ->
      items = instance.mget ['test1', 'test2']
      expect(items).to.exist
      expect(items['test1']).to.not.exist
      expect(items['test2']).to.not.exist

    it 'should get multiple items with some fake items', ->
      items = instance.mget ['1', 'test2']
      expect(items).to.exist
      expect(items['1']).to.exist
      expect(items['test2']).to.not.exist

    it 'should throw error on wrong args', ->
      expect(instance.mget).to.throw(Error)

    it 'should get all keys from cache', ->
      items = instance.keys()
      expect(items).to.exist
      expect(items).to.include.members(['1', '2'])

    it 'should get all keys from empty cache', ->
      instance2 = new Cache()
      items = instance2.keys()
      expect(items).to.exist
      expect(items).to.eql([])

    it 'should get all values from cache', ->
      items = instance.values()
      expect(items).to.exist
      expect(items).to.eql([{prop: true}, {prop: false}])

    it 'should get all values from empty cache', ->
      instance3 = new Cache()
      items = instance3.values()
      expect(items).to.exist
      expect(items).to.eql([])

    it 'should return right item count', ->
      expect(instance.itemCount()).to.eql(2)

    it 'should delete an item', ->
      instance.set '3', {test: true}
      instance.del '1'
      expect(instance.itemCount()).to.eql(2)

    it 'should delete a fake item', ->
      instance.del 'fake1'
      expect(instance.itemCount()).to.eql(2)

    it 'should delete mulitple items', ->
      instance.set '4', {test: false}
      instance.mdel ['2', '3']
      expect(instance.itemCount()).to.eql(1)

    it 'should delete mulitple fake items', ->
      instance.mdel ['fake2', 'fake3']
      expect(instance.itemCount()).to.eql(1)

    it 'should delete multiple items with some fake items', ->
      instance.set '5', {item: true}
      instance.mdel ['fake2', '5']
      expect(instance.itemCount()).to.eql(1)

    it 'should throw error on wrong args', ->
      expect(instance.mdel).to.throw(Error)

    it 'should reset cache', ->
      instance.reset()
      expect(instance.itemCount()).to.eql(0)
      expect(instance.keys()).to.eql([])

  describe 'Expirations with renew option', ->
    before ->
      instance = new Cache
        expirationDelay: 1000
        dispose: (key, value) ->
          diposeFunc(key, value)
          # May use stub or event emitter to test dispoe function
      expect(instance).to.exist

    afterEach ->
      instance.reset()
      expect(instance.keys()).to.eql([])

    it 'should call dipose function after inserting', (done) ->
      @timeout 3000
      key = 'key'
      value = 'value'
      diposeFunc = (_key, _value) ->
        expect(_key).to.eql(key)
        expect(_value).to.eql(value)
        done()

      instance.set key, value

    it 'should NOT call dipose function after deleting', (done) ->
      @timeout 3000
      key = 'key2'
      value = 'value2'
      disposed = false
      
      diposeFunc = (_key, _value) ->
        disposed = true

      instance.set key, value
      instance.del key
      setTimeout ->
        expect(disposed).to.be.false
        done()
      , 1500

    it 'should renew expiration delay on set', ->
    it 'should renew expiration delay on get', ->
    it 'should NOT renew expiration delay on peek', ->

  describe 'Expirations without renew option', ->
  describe 'Clones', ->






