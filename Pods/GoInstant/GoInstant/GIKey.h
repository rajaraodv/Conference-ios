//
//  GIKey.h
//  GoInstantDriver
//
//  Created by Matthew Creaser on 1/20/14.
//  Copyright (c) 2014 GoInstant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GIRoom;
@class GIKey;

@class GISetContext;
@class GIGetContext;
@class GIRemoveContext;
@class GIAddContext;

@class GIAddOptions;
@class GISetOptions;
@class GIRemoveOptions;

typedef void (^GIKeyGetHandler)(NSError* error, id value, GIGetContext *context);
typedef void (^GIKeySetHandler)(NSError* error, id value, GISetContext *context);
typedef void (^GIKeyAddHandler)(NSError* error, id value, GIAddContext *context);
typedef void (^GIKeyRemoveHandler)(NSError* error, id value, GIRemoveContext *context);

@protocol GIKeyObserver<NSObject>
@optional
- (void)key:(GIKey *)key valueSet:(id)value context:(GIGetContext *)context;
- (void)key:(GIKey *)key valueAdded:(id)value context:(GIAddContext *)context;
- (void)key:(GIKey *)key valueRemoved:(id)value context:(GIRemoveContext *)context;
@end

@interface GIKey : NSObject

+ (instancetype)keyWithPath:(NSString *)path room:(GIRoom *)room;
- (instancetype)initWithPath:(NSString *)path room:(GIRoom *)room;

- (void)getValueWithCompletion:(GIKeyGetHandler)block;

- (void)removeValue;
- (void)removeValueWithOptions:(GIRemoveOptions *)options;
- (void)removeValueWithCompletion:(GIKeyRemoveHandler)block;
- (void)removeValueWithOptions:(GIRemoveOptions *)options completion:(GIKeyRemoveHandler)block;

- (void)setValue:(id)value;
- (void)setValue:(id)value options:(GISetOptions *)options;
- (void)setValue:(id)value completion:(GIKeySetHandler)block;
- (void)setValue:(id)value options:(GISetOptions *)options completion:(GIKeySetHandler)block;

- (void)addValue:(id)value;
- (void)addValue:(id)value options:(GISetOptions *)options;
- (void)addValue:(id)value completion:(GIKeyAddHandler)block;
- (void)addValue:(id)value options:(GISetOptions *)options completion:(GIKeyAddHandler)block;

- (GIKey *)childKeyWithName:(NSString *)name;
- (GIKey *)descendentKeyWithPath:(NSString *)path;
- (GIKey *)parentKey;

- (void)subscribe:(id<GIKeyObserver>)observer;
- (void)unsubscribe:(id<GIKeyObserver>)observer;
- (void)unsubscribeAll;

- (BOOL)isEqualToKey:(GIKey *)key;

@property (nonatomic, readonly) GIRoom *room;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSString *name;

@end


