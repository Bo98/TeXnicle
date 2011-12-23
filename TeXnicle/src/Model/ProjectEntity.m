//
//  ProjectEntity.m
//  TeXnicle
//
//  Created by Martin Hewitson on 26/1/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import "ProjectEntity.h"
#import "FileEntity.h"
#import "Settings.h"

@implementation ProjectEntity

@dynamic name;
@dynamic folder;
@dynamic items;
@dynamic type;
@dynamic settings;

- (void) awakeFromInsert
{
	//NSLog(@"Inserted project");
  self.type = @"PDFLaTeX";
  
  // make new settings
  NSEntityDescription *settingsDescription = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
  Settings *newSettings = [[Settings alloc] initWithEntity:settingsDescription insertIntoManagedObjectContext:self.managedObjectContext];   
  self.settings = [newSettings autorelease];
  
}

- (void) awakeFromFetch
{
  [self performSelector:@selector(setupSettings) withObject:nil afterDelay:0];
}

- (void) setupSettings
{
  // make new settings if needed
  if (self.settings == nil) {
    NSEntityDescription *settingsDescription = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:self.managedObjectContext];
    Settings *newSettings = [[Settings alloc] initWithEntity:settingsDescription insertIntoManagedObjectContext:self.managedObjectContext];   
    self.settings = [newSettings autorelease];
  }
}

- (NSSet*)items
{
	[self willAccessValueForKey:@"items"];
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSError *fetchError = nil;
	NSArray *fetchResults;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProjectItem"
																						inManagedObjectContext:moc];
		
	[fetchRequest setEntity:entity];
	fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];	
	[fetchRequest release];	
	
	[self didAccessValueForKey:@"items"];
	return [NSSet setWithArray:fetchResults];
}

- (FileEntity*)fileWithPath:(NSString*)aPath
{
	NSString *pathToTest = aPath;
	if (![[aPath pathExtension] isEqual:@"tex"]) {
		pathToTest = [aPath stringByAppendingPathExtension:@"tex"];
	}
	
//	NSLog(@"Looking for '%@'", aPath);
	for (id item in [self valueForKey:@"items"]) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			FileEntity *file = (FileEntity*)item;
//			NSLog(@"   checking '%@'", [file valueForKey:@"filepath"]);
			NSString *fstr = [file valueForKey:@"filepath"];
			NSRange r = [fstr rangeOfString:pathToTest];
//			if (fstr isEqual:[aPath stringByDeletingPathExtension]]) {
			if (r.location != NSNotFound) {
				return file;
			}
		}
	}
	return nil;
}

- (FileEntity*)fileWithPathOnDisk:(NSString*)aPath
{
	NSString *pathToTest = aPath;
	if (![[aPath pathExtension] isEqual:@"tex"]) {
		pathToTest = [aPath stringByAppendingPathExtension:@"tex"];
	}
	
	//	NSLog(@"Looking for '%@'", aPath);
	for (id item in [self valueForKey:@"items"]) {
		if ([item isKindOfClass:[FileEntity class]]) {			
			FileEntity *file = (FileEntity*)item;
			//			NSLog(@"   checking '%@'", [file valueForKey:@"filepath"]);
			NSString *fstr = [file pathOnDisk];
			NSRange r = [fstr rangeOfString:pathToTest];
			//			if (fstr isEqual:[aPath stringByDeletingPathExtension]]) {
			if (r.location != NSNotFound) {
				return file;
			}
		}
	}
	return nil;
}

- (NSArray*)folders
{
  NSManagedObjectContext *moc = [self managedObjectContext];
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSError *fetchError = nil;
	NSArray *fetchResults;
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder"
																						inManagedObjectContext:moc];
	
	[fetchRequest setEntity:entity];
	fetchResults = [moc executeFetchRequest:fetchRequest error:&fetchError];
	
	if (fetchError != nil) {
		[NSApp presentError:fetchError];
    return nil;
	}
  return fetchResults;
}

@end
