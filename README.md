# FiggyActivationTokens
Lua based implementation of Activation Tokens for Figura (though it should mostly work for Lua in general).
Activation tokens are a tool used to ensure that a boolean value isn't 'fought over'. 

## How to use

### Create a new activation token source.
  
```lua
local myTokenSource = ActivationTokenSource.new()
```

### Requesting an ActivationToken will 'activate' the ActivationTokenSource.
  
```lua
  print(myTokenSource:IsActive()) --prints 'false'

  local token = myTokenSource:RequestToken() --requesting a token will activate the source and return a token

  print(myTokenSource:IsActive()) --prints 'true'
```

### Tokens can be cancelled to notify the ActivationTokenSource.

```lua
  local token = myTokenSource:RequestToken()

  print(myTokenSource:IsActive()) --prints 'true'

  token:Cancel() --cancel the token
  token = nil --discard used token

  print(myTokenSource:IsActive()) --prints 'false' again

```

### An ActivationTokenSource will remain active as long as there is at least one valid ActivationToken belonging to it.

```lua
  local tokenA = myTokenSource:RequestToken()
  local tokenB = myTokenSource:RequestToken()

  print(myTokenSource:IsActive()) --prints 'true'

  tokenA:Cancel() --only cancels this token

  print(myTokenSource:IsActive()) --still prints 'true', as tokenB has not been cancelled

  tokenB:Cancel()

  print(myTokenSource:IsActive()) --prints 'false', as all tokens have been cancelled

```

### You can assign callbacks to the ActivationTokenSource to be notified when it is enabled/disabled

```lua
  local DoSomethingCool = function() end

  local DoSomethingDifferent = function() end

  local DoSomethingElse = function(state) end

  myTokenSource.OnActivation(DoSomethingCool) --reacts when the token source is enabled

  myTokenSource.OnDeactivation(DoSomethingDifferent) --reacts when the token source is disabled

  myTokenSource.OnChange(DoSomethingElse) --reacts when the token source is enabled OR disabled, providing a function with a bool parameter will allow you to easily check the state of the ActivationTokenSource
  
```
