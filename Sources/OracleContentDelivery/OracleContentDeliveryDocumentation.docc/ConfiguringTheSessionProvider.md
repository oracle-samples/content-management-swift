#  Configuring the Session Provider

Describes how to inject your own URLSession objects with specialized configurations into the Delivery library


## Configuring the SessionProvider 
The Delivery library comes with two simple and preconfigured URLSession objects available. Should you wish to provide additional configuration, you have the ability to provide your own implementation of the `SessionProvider` protocol.  

#### Implementation Steps 
- Create a class that conforms to the `OracleContentCore/SessionProvider` provider.
- Provide an implementation for `session` (optional)
- Provide an implementation for `noCacheSession` (optional)
- Assign your class to `Onboarding.sessions`

#### Conforming to Session Provider

```swift
class MySessionProvider: SessionProvider {

   var session: () -> URLSession
   var noCacheSession: () -> URLSession
   
   init() {
      self.session = {
         let config = URLSessionConfiguration.default
         config.timeoutIntervalForRequest = 10
         config.requestCachePolicy = .returnCacheDataElseLoad
         let session = URLSession(configuration: config)
         session.sessionDescription = "DefaultSession"
         return session
      }
   
      self.noCacheSession = {
         let config = URLSessionConfiguration.default
         config.requestCachePolicy = .reloadIgnoringLocalCacheData
         config.urlCache = nil
         let session = URLSession(configuration: config)
         session.sessionDescription = "NoCacheSession"
         return session
      }
   }
}
```

Once you have created your implementation, you need to assign it to the `Onboarding.sessions` property

```swift 
Onboarding.sessions = MySessionProvider()
```



