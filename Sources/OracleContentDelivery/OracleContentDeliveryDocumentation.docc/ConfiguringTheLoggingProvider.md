#  Configuring the Logging Provider 

Describes how to inject your own logging implementation for use in the Delivery library.

## Configuring a Logging Provider 
Out-of-the-box, the Oracle library implementations provide logging interfaces but do not themselves provide any logging implementation. To enable logging, you must inject your own logging code by providing functionality for each of the exposed logging statements.

#### Implementation Steps 
- Create a class that conforms to the `LoggingProvider` provider.
- Provide an implementation for each logging method 
- Assign your class to `Onboarding/logger`

#### Conforming to LoggingProvider
In the following example, we'll create a dummy logging implementation that simply "prints" data to the console for convenience. 

> Tip: In a real application, you would probably choose to provide an implementation that utilizes the the Apple-provided Universal Logger (oslog) or which passes through to some pre-existing logger already in use by your application. Simply "printing" log statements to the console may be nice for development purposes, but it is not recommending for production code.

```swift
class MyLoggingProvider: LoggingProvider {

   func logError(_ message: String, 
                 file: String, 
                 line: UInt, 
                 function: String) {
       print("logError called with message: \(message)")
   }
   
   // User-provided network response logging implementation
   func logNetworkResponseWithData(_ response: HTTPURLResponse?, 
                                   data: Data?,  
                                   file: String, 
                                   line: UInt,
                                   function: String) {
      guard let foundResponse = response else { return }
      print("logNetworkResponseWithData called with response: \(foundResponse)")
   }
   
   // User-provided network requets logging implementation
   func logNetworkRequest(_ request: URLRequest?, 
                          session: URLSession?, 
                          file: String, 
                          line: UInt, 
                          function: String) {
      guard let foundRequest = request else { return }
      print("logNetworkRequest called with request: \(foundRequest)")
   }
   
   // User-provided debug logging implementation
   func logDebug(_ message: String, 
                 file: String, 
                 line: UInt, 
                 function: String) {
      print("logDebug called with message: \(message)")
   } 
}
```

Once you have created your implementation, you need to assign it to the `Onboarding.logger` property

```swift 
Onboarding.logger = MyLoggingProvider()
```

