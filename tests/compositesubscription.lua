subscriptionSpy = function()
  local subscription = Rx.Subscription.create(function() end)
  local unsubscribe = spy(subscription, 'unsubscribe')
  return subscription, unsubscribe
end

describe('CompositeSubscription', function()
  describe('create', function()
    it('returns a CompositeSubscription', function()
      local compositeSubscription = Rx.CompositeSubscription.create()
      expect(compositeSubscription).to.be.an(Rx.CompositeSubscription)
    end)
  end)

  describe('unsubscribe', function()
    it('unsubscribes all subscriptions it was created with', function()
      local subscription1, unsubscribe1 = subscriptionSpy()
      local subscription2, unsubscribe2 = subscriptionSpy()
      local compositeSubscription = Rx.CompositeSubscription.create(subscription1, subscription2)
      compositeSubscription:unsubscribe()
      expect(#unsubscribe1).to.equal(1)
      expect(#unsubscribe2).to.equal(1)
    end)

    it('removes all subscriptions it was created with', function()
      local subscription1, unsubscribe1 = subscriptionSpy()
      local subscription2, unsubscribe2 = subscriptionSpy()
      local compositeSubscription = Rx.CompositeSubscription.create(subscription1, subscription2)
      compositeSubscription:unsubscribe()
      compositeSubscription:unsubscribe()
      expect(#unsubscribe1).to.equal(1)
      expect(#unsubscribe2).to.equal(1)
    end)

    it('unsubscribes all subscriptions that were added to it', function()
      local subscription1, unsubscribe1 = subscriptionSpy()
      local subscription2, unsubscribe2 = subscriptionSpy()
      local compositeSubscription = Rx.CompositeSubscription.create()
      compositeSubscription:add(subscription1, subscription2)
      compositeSubscription:unsubscribe()
      expect(#unsubscribe1).to.equal(1)
      expect(#unsubscribe2).to.equal(1)
    end)

    it('removes all subscriptions that were added to it', function()
      local subscription1, unsubscribe1 = subscriptionSpy()
      local subscription2, unsubscribe2 = subscriptionSpy()
      local compositeSubscription = Rx.CompositeSubscription.create()
      compositeSubscription:add(subscription1, subscription2)
      compositeSubscription:unsubscribe()
      compositeSubscription:unsubscribe()
      expect(#unsubscribe1).to.equal(1)
      expect(#unsubscribe2).to.equal(1)
    end)
  end)

  it('can be reused after it has been unsubscribed', function()
    local compositeSubscription = Rx.CompositeSubscription.create()

    local subscription1 = subscriptionSpy()
    compositeSubscription:add(subscription1)
    compositeSubscription:unsubscribe()

    local subscription2, unsubscribe2 = subscriptionSpy()
    compositeSubscription:add(subscription2)
    compositeSubscription:unsubscribe()

    expect(#unsubscribe2).to.equal(1)
  end)
end)