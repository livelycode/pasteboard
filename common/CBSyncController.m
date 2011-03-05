//
//  SyncController.m
//  cloudboard
//
//  Created by Mirko on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CBSyncController.h"

@implementation CBSyncController
- (id)initWithClipboardController: (CBClipboardController*) aSyncController {
  self = [super init];
  if (self) {
    clipboardController = [aSyncController retain];
    [clipboardController addChangeListener: self];
    delegates = [[NSMutableArray alloc] init];
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
    
    clientsVisible = [[NSMutableDictionary alloc] init];
    clientsConnected = [[NSMutableDictionary alloc] init];
    clientsIAwaitConfirm = [[NSMutableDictionary alloc] init];
    
    clientsToSearch = [[NSMutableArray alloc] init];
    clientsUserNeedsToConfirm = [[NSMutableArray alloc] init];
    clientsQueuedForConfirm = [[NSMutableArray alloc] init];
    
    NSMutableString* tempServiceString = [NSMutableString string];
    [tempServiceString appendString: @"Cloudboard "];
    [tempServiceString appendString: [[NSHost currentHost] name]];
    myServiceName = [[NSString alloc] initWithString:tempServiceString];
    
    [self launchHTTPServer];
    [self searchRemotes];
  }
  return self;
}

- (void)addDelegate:(id<CBSyncControllerProtocol>)delegate {
  if([delegates containsObject:delegate] == NO) {
    [delegates addObject:delegate];
  }
}

-(NSString*) serviceName {
  return myServiceName;
}

- (void)syncItem: (CBItem*)item atIndex: (NSInteger)index {
  for(CBRemoteCloudboard* client in [clientsConnected allValues]) {
    NSLog(@"sync to client: %@", [client serviceName]);
    [client syncItem: item atIndex: index];
  }
}

- (void)setClientsToSearch:(NSArray *)clientNames {
  clientsToSearch = [[NSMutableArray alloc] initWithArray: clientNames];
}

- (void)addClientToSearch:(NSString *)clientName {
  if([clientsToSearch containsObject:clientName] == NO) {
    [clientsToSearch addObject:clientName];
  }
}

- (NSArray*)visibleClients {
  return [clientsVisible allKeys];
}

- (NSArray*)connectedClients {
  return [clientsConnected allKeys];
}

- (NSArray*)clientsRequiringUserConfirm {
  return clientsUserNeedsToConfirm;
}

- (void)dealloc {
  [serviceBrowser release];
  [clientsConnected release];
  [myServiceName release];
  [clipboardController release];
  [super dealloc];
}
@end

@implementation CBSyncController(Private)

- (void)launchHTTPServer {
  httpServer = [[HTTPServer alloc] init];
  
  // Tell the server to broadcast its presence via Bonjour.
  [httpServer setType:@"_http._tcp."];
  [httpServer setName:myServiceName];
  //[httpServer setPort:8090];
  [httpServer setConnectionClass:[CBHTTPConnection class]];
  
  NSError *error = nil;
  if(![httpServer start:&error]) {
    NSLog(@"Error starting HTTP Server: %@", error);
  } else {
    NSLog(@"Server started");
  }
}

- (void) searchRemotes {
  NSLog(@"invoke search");
  [serviceBrowser searchForServicesOfType:@"_http._tcp." inDomain:@"local."];    
}

- (void)foundClient:(CBRemoteCloudboard *)client {
  NSLog(@"found client: %@", [client serviceName]);
  [clientsVisible setValue:client forKey:[client serviceName]];
  [self informDelegatesWith:@selector(clientBecameVisible:) object:[client serviceName]];
  if([clientsQueuedForConfirm containsObject:[client serviceName]]) {
    [self confirmClient:client];
    [clientsQueuedForConfirm removeObject:[client serviceName]];
  }
  if([self clientToRegister:client]) {
    [client registerAsClient];
    [clientsIAwaitConfirm setValue:client forKey:[client serviceName]];
  }
}

- (BOOL)clientToRegister:(CBRemoteCloudboard*)client {
  //only for testing:
  return true;
  if([clientsToSearch containsObject:[client serviceName]]) {
    CBRemoteCloudboard* alreadyRegisteredClient = [clientsConnected objectForKey:[client serviceName]];
    if(alreadyRegisteredClient == nil) {
      return YES;
    } else {
      return NO;
    }
  } else {
    return NO;
  }
}

- (void)confirmClient:(CBRemoteCloudboard*)client {
  [client confirmClient];
  [self informDelegatesWith:@selector(clientConfirmed:) object:[client serviceName]];
}

- (void)initialSyncToClient:(CBRemoteCloudboard *)client {
  NSLog(@"starting initial sync to %@", [client serviceName]);
  NSInteger index = 0;
  for(CBItem* item in [clipboardController allItems]) {
    [self syncItem:item atIndex:index];
    index++;
  }
}

- (void)informDelegatesWith:(SEL)selector object:(id)object {
  for(id<CBSyncControllerProtocol> delegate in delegates) {
    if([delegate respondsToSelector:selector]) {
      [delegate performSelector:selector withObject:object];
    }
  }
}
@end

@implementation CBSyncController(Delegation)

//NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
  NSLog(@"searching services");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo {
  NSLog(@"error: did not search services %@", errorInfo);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindDomain:(NSString *)domainName moreComing:(BOOL)more {
  NSLog(@"found domain: %@", domainName);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *) browser didFindService: (NSNetService*) newService moreComing: (BOOL)more; {
  NSLog(@"found service: %@ on port: %i, more coming: %i", newService, [newService port], more);
  if([[newService name] hasPrefix: @"Cloudboard"] & ([[newService name] isEqual: myServiceName] == NO)) {
    CBRemoteCloudboard* client = [[CBRemoteCloudboard alloc] initWithService:newService syncController:self];
    [self foundClient:client];
  }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *) browser didRemoveService: (NSNetService*) netService moreComing: (BOOL)more {
  NSLog(@"removed service: %@", netService);
  if([[netService name] hasPrefix: @"Cloudboard"]) {
    [self informDelegatesWith:@selector(clientBecameInvisible:) object:[netService name]]; 
  }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser {
  NSLog(@"stopped searching");
}

//CBClipboardControllerDelegate
- (void)didSetItem:(CBItem*)item atIndex: (NSInteger) index {
  NSLog(@"sync item");
  [self syncItem: item atIndex: index];
  NSLog(@"received notification");
}

//CBHTTPConnectionDelegate
- (void)registrationRequestFrom:(NSString *)clientName {
  if([clientsToSearch containsObject:clientName]) {
  //always true for testing:
  //if(YES) {
    CBRemoteCloudboard* visibleClient = [clientsVisible objectForKey:clientName];
    if(visibleClient) {
      [self confirmClient:visibleClient];
    } else {
      [clientsQueuedForConfirm addObject:clientName];    
    }
  } else {
    [self informDelegatesWith:@selector(clientRequiresUserConfirmation:) object:clientName];
  }
}

- (void)registrationConfirmationFrom:(NSString *)serviceName {
  CBRemoteCloudboard* client = [clientsIAwaitConfirm objectForKey:serviceName];
  [clientsConnected setValue:client forKey:serviceName];
  [clientsIAwaitConfirm setValue:nil forKey:serviceName];
  [self informDelegatesWith:@selector(clientConnected:)object:serviceName];
  [self initialSyncToClient: client];
}

- (void)receivedRemoteItem: (CBItem*)item atIndex: (NSInteger) index {
  NSLog(@"received item: %@", [[item string] string]);
  [clipboardController setItemQuiet:item atIndex:index];
}
@end