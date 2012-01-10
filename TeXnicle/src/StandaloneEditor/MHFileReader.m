//
//  MHFileReader.m
//  TeXnicle
//
//  Created by Martin Hewitson on 31/8/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "MHFileReader.h"
#import "UKXattrMetadataStore.h"
#import "NSString+FileTypes.h"
#import "externs.h"

@implementation MHFileReader
@synthesize encodings;
@synthesize encodingNames;
@synthesize selectedIndex;

+ (NSStringEncoding)defaultEncoding
{
  NSString *defaultEncodingName = [[NSUserDefaults standardUserDefaults] valueForKey:TPDefaultEncoding];
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
  return [fr encodingWithName:defaultEncodingName];
}

- (id) init
{
  self = [super initWithNibName:@"MHFileReader" bundle:nil];
  if (self) {
    self.encodingNames = [NSArray arrayWithObjects:
                          @"ASCII",
                          @"Unicode (UTF-8)",
                          @"Unicode (UTF-16)",
                          @"Unicode (UTF-16 Little-Endian)",
                          @"Unicode (UTF-16 Big-Endian)",
                          @"Western (ISO Latin 1)",
                          @"Western (ISO Latin 9)",
                          @"Western (Mac OS Roman)",
                          @"Western (Windows Latin 1)",
                          nil];                      
    
    self.encodings = [NSArray arrayWithObjects:
                      [NSNumber numberWithInteger:NSASCIIStringEncoding],
                      [NSNumber numberWithInteger:NSUTF8StringEncoding],
                      [NSNumber numberWithInteger:NSUTF16StringEncoding],
                      [NSNumber numberWithInteger:NSUTF16LittleEndianStringEncoding],
                      [NSNumber numberWithInteger:NSUTF16BigEndianStringEncoding],
                      [NSNumber numberWithInteger:NSISOLatin1StringEncoding],
                      [NSNumber numberWithInteger:NSISOLatin2StringEncoding],
                      [NSNumber numberWithInteger:NSMacOSRomanStringEncoding],
                      [NSNumber numberWithInteger:NSWindowsCP1251StringEncoding],
                      nil];
    self.selectedIndex = [NSNumber numberWithInteger:1];
 }
  return self;
}

- (id) initWithEncodingNamed:(NSString*)encodingName
{
  self = [self init];
  if (self) {
    self.selectedIndex = [NSNumber numberWithInteger:[self indexForEncodingNamed:encodingName]];
  }
  return self;
}

- (id) initWithEncoding:(NSStringEncoding)encoding
{
  self = [self init];
  if (self) {
    self.selectedIndex = [NSNumber numberWithInteger:[self indexForEncoding:encoding]];
  }
  return self;
}

- (void) dealloc
{
  self.encodings = nil;
  self.selectedIndex = nil;
  self.encodingNames = nil;
  [super dealloc];
}

- (NSString*)defaultEncodingName
{
  return [self.encodingNames objectAtIndex:[self.selectedIndex integerValue]];
}

- (NSStringEncoding) defaultEncoding
{
  NSString *defaultEncodingName = [[NSUserDefaults standardUserDefaults] valueForKey:TPDefaultEncoding];
//  NSLog(@"Getting default encoding...%@", defaultEncodingName);
  return [self encodingWithName:defaultEncodingName];
  //  return [[self.encodings objectAtIndex:[self.selectedIndex integerValue]] integerValue];
}

- (NSInteger)indexForEncoding:(NSStringEncoding)encoding
{
  NSInteger idx = 0;
  for (NSNumber *enc in self.encodings) {
    if ([enc integerValue] == encoding) {
      return idx;
    }
    idx++;
  }
  
  return NSNotFound;
}

                              
- (NSInteger)indexForEncodingNamed:(NSString*)encoding
{
  NSInteger idx = 0;
  for (NSString *enc in self.encodingNames) {
    if ([enc isEqualToString:encoding]) {
      return idx;
    }
    idx++;
  }
        
  return NSNotFound;
}

- (NSStringEncoding)encodingWithName:(NSString*)encoding
{  
  NSInteger idx = [self indexForEncodingNamed:encoding];
  return [[self.encodings objectAtIndex:idx] integerValue];
}

- (NSString*)nameOfEncoding:(NSStringEncoding)encoding
{
  NSInteger idx = 0;
  for (NSNumber *e in self.encodings) {
    if ([e integerValue] == encoding) {
      return [self.encodingNames objectAtIndex:idx];
    }
    idx++;
  }
  return nil;
}


- (BOOL)writeDataToFileAsString:(NSData*)data toURL:(NSURL*)aURL
{
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  
  NSError *error = nil;
  NSString *content = [[[NSString alloc] initWithData:data
                                            encoding:encoding] autorelease];
  [content writeToURL:aURL atomically:YES encoding:encoding error:&error];
  if (error) {
    [NSApp presentError:error];
    return NO;
  }
  
  return YES;
}


- (BOOL)writeString:(NSString*)aString toURL:(NSURL*)aURL withEncoding:(NSStringEncoding)encoding
{
  
  NSError *error = nil;
  [aString writeToURL:aURL atomically:YES encoding:encoding error:&error];
  if (error) {
    [NSApp presentError:error];
    return NO;
  }
  
  [UKXattrMetadataStore setString:[self nameOfEncoding:encoding]
                           forKey:@"com.bobsoft.TeXnicleTextEncoding"
                           atPath:[aURL path]
                     traverseLink:YES];
  
  return YES;
}

- (BOOL)writeString:(NSString*)aString toURL:(NSURL*)aURL
{
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  
  return [self writeString:aString toURL:aURL withEncoding:encoding];
}

- (NSString*)readStringFromFileAtURL:(NSURL*)aURL
{
  
  if (![[aURL path] pathIsText]) {
    return nil;
  }
  
  NSError *error = nil;
  
  // check the xattr for a string encoding
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:[aURL path]
                                                   traverseLink:YES];
  NSString *str = nil;
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    
    str = [NSString stringWithContentsOfURL:aURL usedEncoding:&encoding error:&error];
    //    NSLog(@"Loaded string %@", str);
    // if we didn't get a string, then try the default encoding
    if (str == nil) {
      //      NSLog(@"   failed to guess.");
      encoding = [self defaultEncoding];
      //      NSLog(@" using default encoding %@", [self nameOfEncoding:encoding]);
    }
    
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  //  NSLog(@"Reading string with encoding %@", encodingString);
  // if we didn't get the string, try with the default encoding
  if (str == nil) {
    error = nil;
    str = [NSString stringWithContentsOfURL:aURL
                                   encoding:encoding
                                      error:&error];
    
  }  
  
  //  NSLog(@"Loaded string %@", str);
  
  if (str == nil) {
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"Loading Failed"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"Failed to open %@ with encoding %@. Open with another encoding?", [aURL path], [self nameOfEncoding:encoding]];
    [alert setAccessoryView:self.view];
    NSInteger result = [alert runModal];
    if (result == NSAlertDefaultReturn)       
    {
      // get the encoding the user selected
      encoding = [[self.encodings objectAtIndex:[self.selectedIndex integerValue]] integerValue];
      str = [NSString stringWithContentsOfURL:aURL
                                     encoding:encoding
                                        error:&error];
      
    }
  }
  
  if (str != nil) {
    if (![[self nameOfEncoding:encoding] isEqualToString:encodingString]) {
      [UKXattrMetadataStore setString:[self nameOfEncoding:encoding]
                               forKey:@"com.bobsoft.TeXnicleTextEncoding"
                               atPath:[aURL path]
                         traverseLink:YES];
    }
  }
  
  // set the encoding we used in the end
  self.selectedIndex = [NSNumber numberWithInteger:[self indexForEncoding:encoding]];
  
  return str;
}

- (NSStringEncoding)encodingForFileAtPath:(NSString*)aPath
{
  
  NSString *encodingString = [UKXattrMetadataStore stringForKey:@"com.bobsoft.TeXnicleTextEncoding"
                                                         atPath:aPath
                                                   traverseLink:YES];
  NSStringEncoding encoding;
  if (encodingString == nil || [encodingString length] == 0) {
    encoding = [self defaultEncoding];
  } else {
    encoding = [self encodingWithName:encodingString];
  }
  return encoding;
}

- (NSStringEncoding)encodingUsed
{
  return [[self.encodings objectAtIndex:[self.selectedIndex integerValue]] integerValue];
}

@end
