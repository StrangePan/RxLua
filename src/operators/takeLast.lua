local Observable = require 'observable'
local Subscription = require 'subscription'
local util = require 'util'

--- Returns an Observable that produces a specified number of elements from the end of a source
-- Observable. To accomplish this, the operator maintains an internal buffer to track incoming
-- values, deferring their emission until the source completes.
-- following items are emitted.
-- @arg {number} count - The number of elements to produce.
-- @returns {Observable}
function Observable:takeLast(count)
  if not count or type(count) ~= 'number' then
    error('Expected a number')
  end

  if count <= 0 then
    observer:onCompleted()
    return Subscription.empty()
  end

  return Observable.create(function(observer)
    local buffer = {}
    local subscription

    local function onNext(...)
      table.insert(buffer, util.pack(...))
      if #buffer > count then
        table.remove(buffer, 1)
      end
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onCompleted()
      subscription:unsubscribe()
      for _,value in ipairs(buffer) do
        observer:onNext(util.unpack(value))
      end
      return observer:onCompleted()
    end

    subscription = self:subscribe(onNext, onError, onCompleted)
    return subscription
  end)
end
