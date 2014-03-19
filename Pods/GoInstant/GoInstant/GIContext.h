//
//  GIContext.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/20/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIKey;
@class GIRoom;
@class GIUser;
@class GIConnection;

typedef NS_ENUM(NSInteger, GIContextCommand) {
  GIContextCommandGet,
  GIContextCommandSet,
  GIContextCommandAdd,
  GIContextCommandRemove,

  GIContextCommandUnknown
};

@interface GIContext : NSObject

/**
 The event that occured.
 */
@property (atomic, readonly) GIContextCommand command;

/**
 The key whose value has changed.
 */
@property (atomic, readonly) GIKey *key;

/**
 The value of the key after the operation.
 */
@property (atomic, readonly) id value;

/**
 The room in which the key exists
 */
@property (atomic, readonly) GIRoom *room;

/**
 The user who initiated the action. If the user has left the room this will be nil
 */
@property (atomic, readonly) GIUser *user;

/**
 The The ID of the user who initiated the action.
 */
@property (atomic, readonly) NSString *userId;

@end



@interface GISetContext : GIContext
/**
 The set of keys that will cascade the operated on key.
 */
@property (atomic, readonly) NSArray *cascade;

@end



@interface GIGetContext : GISetContext
/**
 Indicates whether or not the 'set' operation overwrote an existing value.
 */
@property (atomic, readonly) Boolean overwritten;

@end



@interface GIAddContext : GIGetContext

/**
 Only appears in the context during 'add' events. This value is the path to the added child-key.
 */
@property (atomic, readonly) GIKey *addedKey;

@end



@interface GIRemoveContext : GIContext
/**
 Indicates whether or not a key has been removed from cascading.
 */
@property (atomic, readonly) Boolean cascaded;

/**
 Indicates whether or not the key has expired
 */
@property (atomic, readonly) Boolean expired;

@end
