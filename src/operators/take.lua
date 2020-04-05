local Observable = require 'observable'
local Subscription = require 'subscription'

--- Returns a new Observable that only produces the first n results of the original.
-- @arg {number=1} n - The number of elements to produce before completing.
-- @returns {Observable}
function Observable:take(n)
  n = n or 1

  return Observable.create(function(observer)
    if n <= 0 then
      observer:onCompleted()
      return Subscription.empty()
    end

    local i = 1
    local taking = true
    local subscription = nil

    local function onNext(...)
      if taking then
        i = i + 1

        taking = (i <= n)

        if not taking then
          subscription:unsubscribe()
        end

        observer:onNext(...)

        if not taking then
          observer:onCompleted()
        end
      end
    end

    local function onError(e)
      if taking then
        return observer:onError(e)
      end
    end

    local function onCompleted()
      if taking then
        return observer:onCompleted()
      end
    end

    subscription = self:subscribe(onNext, onError, onCompleted)
    return subscription
  end)
end
