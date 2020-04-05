local Observable = require 'observable'
local CompositeSubscription = require 'compositesubscription'

--- Returns a new Observable that completes when the specified Observable emits a value, encounters
-- an error, or completes.
-- @arg {Observable} other - The Observable that triggers completion of the original upon first
--                           emission.
-- @returns {Observable}
function Observable:takeUntil(other)
  return Observable.create(function(observer)
    local stopped = false
    local subscription = CompositeSubscription()

    local function onOther()
      stopped = true
      subscription:unsubscribe()
      observer:onCompleted()
    end

    local function onNext(...)
      if not stopped then
        return observer:onNext(...)
      end
    end

    local function onError(e)
      if not stopped then
        return observer:onError(e)
      end
    end

    local function onCompleted()
      if not stopped then
        return observer:onCompleted()
      end
    end

    subscription:add(
        other:subscribe(onOther, onOther, onOther),
        self:subscribe(onNext, onError, onCompleted))
    return subscription
  end)
end
