expect = require('chai').expect
sinon = require 'sinon'
clone = require 'clone'


Cache = require("../")

instance = null
disposeFunc = null
clock = sinon.useFakeTimers()


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
      disposeFunc = sinon.spy()
      instance = new Cache
        expirationDelay: 1000
        dispose: (key, value) ->
          disposeFunc(key, value)
          # May use stub or event emitter to test dispose function
      expect(instance).to.exist

    afterEach ->
      clock.restore()
      disposeFunc.reset()
      instance.reset()
      expect(instance.keys()).to.eql([])

    it 'should call dipose function after inserting', ->
      @timeout 3000
      key = 'key'
      value = 'value'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      clock.tick(1001)
      expect(disposeFunc.withArgs(key, value).calledOnce).to.be.true
      expect(disposeFunc.calledOnce).to.be.true

    it 'should NOT call dipose function after deleting', ->
      key = 'key2'
      value = 'value2'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      instance.del key
      clock.tick(1001)
      expect(disposeFunc.withArgs(key, value).called).to.be.false
      expect(disposeFunc.called).to.be.false

    it 'should renew expiration delay on set', (done) ->
      @timeout 3000
      key = 'key3'
      value = 'value3'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      setTimeout ->
        expect(disposeFunc.called).to.be.false
        instance.set key, value
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 1500
      , 500

    it 'should renew expiration delay on set with new delay option'
    , (done) ->
      @timeout 3000
      key = 'key4'
      value = 'value4'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      setTimeout ->
        instance.set key, value, 500
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 1000
      , 500

    it 'should renew expiration delay on get', (done) ->
      @timeout 3000
      key = 'key5'
      value = 'value5'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      setTimeout ->
        instance.get key
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 1500
      , 500

    it 'should renew expiration delay on get using older delay'
    , (done) ->
      @timeout 3000
      key = 'key6'
      value = 'value6'
      disposeFunc.withArgs(key, value)

      instance.set key, value, 500
      setTimeout ->
        instance.get key
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 750
      , 250

    it 'should NOT renew expiration delay on peek'
    , (done) ->
      @timeout 2000
      key = 'key7'
      value = 'value7'
      disposeFunc.withArgs(key, value)

      instance.set key, value, 500
      setTimeout ->
        instance.peek key
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 300
      , 250

  describe 'Expirations without renew option', ->
    before ->
      instance = new Cache
        expirationDelay: 1000
        renewExpiration: false
        dispose: (key, value) ->
          disposeFunc(key, value)
          # May use stub or event emitter to test dispose function
      expect(instance).to.exist

    afterEach ->
      instance.reset()
      expect(instance.keys()).to.eql([])

    it 'should expire even if item changes', (done) ->
      @timeout 2000
      key = 'key8'
      value = 'value8'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      setTimeout ->
        instance.set key, value
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 1000
      , 500

    it 'should expire even after a get call', (done) ->
      @timeout 2000
      key = 'key9'
      value = 'value9'
      disposeFunc.withArgs(key, value)

      instance.set key, value
      setTimeout ->
        instance.get key
        setTimeout ->
          expect(disposeFunc.withArgs(key, value).called).to.be.true
          expect(disposeFunc.called).to.be.true
          done()
        , 1000
      , 500

  describe 'Clones', ->
    afterEach ->
      instance.reset()
      expect(instance.keys()).to.eql([])

    it 'should return object at the inserted state', (done) ->
      instance = new Cache
        expirationDelay: 1000
        dispose: (key, value) ->
          disposeFunc(key, value)

      expect(instance).to.exist

      obj = {prop: true, sub: {test: true}}
      refObj = clone(obj)
      key = 'obj'
      cachedObj = null
      disposeFunc = (_key, _value) ->
        cachedObj = _value

      instance.set key, obj
      obj.sub.test = false
      gettedObj = instance.get(key)
      expect(gettedObj).to.deep.eql(refObj)
      expect(gettedObj).to.not.deep.eql(obj)
      setTimeout ->
        expect(cachedObj).to.deep.eql(refObj)
        expect(cachedObj).to.not.deep.eql(obj)
        done()
      , 1250

    it 'should return object at the current state', (done) ->
      instance = new Cache
        expirationDelay: 1000
        useClones: false
        dispose: (key, value) ->
          disposeFunc(key, value)

      expect(instance).to.exist

      obj = {prop: true, sub: {test: true}}
      key = 'obj'
      cachedObj = null
      disposeFunc = (_key, _value) ->
        cachedObj = _value

      instance.set key, obj
      obj.sub.test = false
      gettedObj = instance.get(key)
      expect(gettedObj).to.deep.eql(obj)
      setTimeout ->
        expect(cachedObj).to.deep.eql(obj)
        done()
      , 1250
