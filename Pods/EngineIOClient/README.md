engine.io-objc
==============

## Using

You implement something conforming to the following protocol:

```objc
@protocol EngineIODelegate<NSObject>
@optional

- (void)engineIODidConnect:(EngineIOClient *)client;
- (void)engineIO:(EngineIOClient *)client didReceiveMessage:(NSData *)message;
- (void)engineIO:(EngineIOClient *)client didDisconnectWithError:(NSError *)error;

@end
```

Then you can connect to an engine.io server like so:

```objc
EngineIOClient *eio = [EngineIOClient clientWithDelegate:self];
[eio connectToHost:@"localhost" onPort:3000];
```

You can start sending messages immediately, but they may be queued internally
until the client is connected.

```objc
NSData *data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
[eio sendMessage:data];
```

## Building

Install dependencies using [Cocoapods](http://cocoapods.org/):

```
$ pod install
```

Open `EngineIOClient.xcworkspace`. Build!
