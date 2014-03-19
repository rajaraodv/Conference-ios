//
//  GIError.h
//  GoInstant
//
//  Created by Jeremy Wright on 2/17/14.
//  Copyright (c) 2014 Jeremy Wright. All rights reserved.
//

#import <Foundation/Foundation.h>

// XXX: Some of these need more complete documentation. There is an open issue to fully document these publicly.
typedef NS_ENUM(NSInteger, GIErrorCode) {
  /**
   *  Generic error which does not fall into current error specifications.
   */
  GIGenericError = 0,

  /**
   *  Key overwrite failure
   *  Occurs when [GIOptions optionsWithOverwrite:NO] is passed to an operation that would have overwritten an already-set key (e.g. [GIKey set]).
   */
  GICollisionError = 100,

  /**
   *  Bad join/leave operation
   *  Occurs when an attempt to do one of the following is made:
   *
   *  - join a Room that has already been joined by this Connection object, or
   *  - leave a Room that has previously been left by this Connection object
   */
  GIRoomSessionStateError = 200,

  /**
   *  Too many users in a Room
   *  Occurs when a Room occupancy limit has been reached. Room limits are defined by your account plan with GoInstant.
   */
  GIRoomSizeError,

  /**
   *  Network-level connection problems
   *  Occurs when an unrecoverable network-level error is encountered. Examples:
   *
   *  - During initial connection establishment, a network error occurs
   *  - Hostname resolution failure
   *  - A JWT is being used, but it is -- or becomes -- invalid.
   *  - When reconnecting after a network drop-out, a timeout or retry limit is reached
   *  - An operation was interrupted due to the client becoming permanently disconnected (after reaching a retry count/time limit)
   *
   *  Note that temporary network-level disconnections are handled automatically by GoInstant; only permanent connection errors will cause this error to be emitted.
   */
  GIConnectionError,

  /**
   *  Unable to authenticate
   *  Occurs when the credentials for a user could not be validated. This can happen when an invalid JWT is passed to connection.
   */
  GIAuthenticationError,

  /**
   *  Unable to authorize an action
   *  Occurs when an operation is denied based on who is attempting that operation. For example, an ACL can be written to deny some users the set operation on specific keys.
   */
  GIPermissionError,

  /**
   *  Not joined to the Room to which a Key belongs
   *  Occurs when the GoInstant server does extra client-request validation and finds something wrong with the request itself, e.g., the value too large, the request is malformed, etc.
   */
  GINotMemberError,

  /**
   *  Connection required
   *  Occurs when an operation is attempted that requires a live connection to GoInstant. For example, if a room join is attempted without connecting this error will be returned.
   */
  GINotConnectedError,

  /**
   *  Attempt to set data on a user that does not exist
   *  Occurs when attempting to operate on a User, but the User does not exist.
   */
  GINoUserError,

  /**
   *  XXX: Needs doccumentation
   */
  GISynchronizationError,

  /**
   *  Key name is not valide
   *  Occurs when an invalid name is passed to the Room#key or Room#channel constructors.
   */
  GIKeyNameError = 300,

  /**
   Server-side request validation failure
   */
  GIInvalidRequestError,

  /**
   *  The arguments provided with the request is invalid. The most common cause is operating on a key with an invalid name.
   */
  GIArgumentError,

  /**
   *  XXX: Needs doccumentation
   */
  GINonLeafKeyError,

  /**
   *  XXX: Needs doccumentation
   */
  GIDuplicateCallError,

  /**
   *  XXX: Needs doccumentation
   */
  GICouldNotCompleteError,

  /**
   *  XXX: Needs doccumentation
   */
  GINotInitializedError
};