--ACTIVATION TOKENS

local ActivationTokenCallback

ActivationToken = {}
  ActivationToken.new = function(tokenSource)
    local instance = {}
      instance.source = tokenSource
      instance.IsValid = function() return not(tokenSource == nil) end
      instance.Cancel = function(self)
        if(tokenSource) then tokenSource:CancelToken(self) end
        tokenSource = nil
      end
    return instance
  end

ActivationTokenSource  = {}

  ActivationTokenSource.new = function()
    local instance = {}

    instance.activeTokens = {}
    instance.prevTokenCount = 0
    instance.OnActivation = function(source, func)
      assert(type(func) == "function", "OnActivation Callback must be a Function. ("..type(func).." was provided)")
      table.insert(instance.activationCallbacks, ActivationTokenCallback.new(source, func))
    end
    instance.deactivationCallbacks = {}
    instance.OnDeactivation = function(source, func)
      assert(type(func) == "function", "OnDeactivation Callback must be a Function. ("..type(func).." was provided)")
      table.insert(instance.deactivationCallbacks, ActivationTokenCallback.new(source, func))
    end
    instance.changeCallbacks = {}
    instance.OnChange = function(source, func)
      assert(type(func) == "function", "OnChange Callback must be a Function. ("..type(func).." was provided)")
      table.insert(instance.changeCallbacks, ActivationTokenCallback.new(source, func))
    end
    instance.activationCallbacks = {}
    instance.IsActive = function(self)
      return (#self.activeTokens > 0)
    end
    instance.RequestToken = function(self)
      local newToken = ActivationToken.new(self)
      table.insert(self.activeTokens, newToken)
      self:UpdateState()
      return newToken
    end
    instance.CancelToken = function(self, token)
      for key, value in pairs(self.activeTokens) do
        if(value == token) then
          table.remove(self.activeTokens, key)
          self:UpdateState()
        end
      end
    end

    instance.UpdateState = function(self)
      if(not(#self.activeTokens == self.prevTokenCount)) then
        if(self.prevTokenCount == 0) then
          for key, value in pairs(self.activationCallbacks) do
            if(not(value.source == nil)) then --notify subscribers that tokenSource was activated
              value.func(value.source)
            else
              value.func()
            end
          end
          for key, value in pairs(self.changeCallbacks) do
            if(not(value.source == nil)) then --notify subscribers that tokenSource was activated
              value.func(value.source,true)
            else
              value.func(true)
            end
          end
        end
        if(#self.activeTokens == 0) then
          for key, value in pairs(self.deactivationCallbacks) do
            if(not(value.source == nil)) then --notify subscribers that tokenSource was dectivated
              print(value.func)
              value.func(value.source)
            else
              value.func()
            end
          end
          for key, value in pairs(self.changeCallbacks) do
            if(not(value.source == nil)) then --notify subscribers that tokenSource was dectivated
              value.func(value.source, false)
            else
              value.func(false)
            end
          end
        end
        self.prevTokenCount = #self.activeTokens
      end
    end

  return instance
  end

  ActivationTokenCallback = {}
  ActivationTokenCallback.new = function(source, func)
    local instance = {}
    instance.source = source
    instance.func = func
    return instance
  end