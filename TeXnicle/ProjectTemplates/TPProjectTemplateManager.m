//
//  TPProjectTemplateChooser.m
//  TeXnicle
//
//  Created by Martin Hewitson on 19/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPProjectTemplateManager.h"
#import "TPProjectTemplateCreator.h"
#import "TPProjectTemplate.h"
#import "TPProjectTemplateViewer.h"
#import "MABSupportFolder.h"

@interface TPProjectTemplateManager ()

@end

@implementation TPProjectTemplateManager
@synthesize editButton;
@synthesize duplicateButton;
@synthesize deleteButton;
@synthesize revealButton;
@synthesize templateListViewController;
@synthesize templateListContainer;

- (id)init
{
  self = [super initWithNibName:@"TPProjectTemplateManager" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) dealloc
{
  self.templateListViewController = nil;
  [super dealloc];
}

- (void) awakeFromNib
{
  self.templateListViewController = [[[TPProjectTemplateListViewController alloc] init] autorelease];
  [self.templateListViewController.view setFrame:[self.templateListContainer bounds]];
  [self.templateListContainer addSubview:self.templateListViewController.view];
}


+ (NSString*)templatesDir
{
  MABSupportFolder *sf = [MABSupportFolder sharedController];
  return [[sf supportFolder] stringByAppendingPathComponent:@"projectTemplates"];
}

+ (void)installBundleTemplates
{
  NSArray *templatesToInstall = [NSArray arrayWithObjects:@"Article", nil];  
  NSFileManager *fm = [NSFileManager defaultManager];
  
  // make sure the templates directory exists
  NSError *error = nil;
  [fm createDirectoryAtPath:[TPProjectTemplateManager templatesDir] withIntermediateDirectories:YES attributes:nil error:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }
  
  // get the bundle path to any .tpt files
  for (NSString *template in templatesToInstall) {
    NSString *source = [[NSBundle mainBundle] pathForResource:template ofType:@"tpt"];
    
    NSString *destination = [[[TPProjectTemplateManager templatesDir] stringByAppendingPathComponent:template] stringByAppendingPathExtension:@"tpt"];
    
    // check if the destination exists
    if (![fm fileExistsAtPath:destination]) {
      error = nil;
      [fm copyItemAtPath:source toPath:destination error:&error];
      if (error) {
        [NSApp presentError:error];
      }
    }
  }
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
  TPProjectTemplate *template = [self.templateListViewController selectedTemplate];
  
  if (anItem == self.editButton) {
    if (template == nil || template.isBuiltIn) {
      return NO;
    }
  }
  
  if (anItem == self.duplicateButton) {
    if (template == nil) {
      return NO;
    }
  }
  
  if (anItem == self.deleteButton) {
    if (template == nil) {
      return NO;
    }
  }

  if (anItem == self.revealButton) {
    if (template == nil) {
      return NO;
    }
  }
  
  return YES;
}



- (IBAction)revealSelectedTemplate:(id)sender
{
  TPProjectTemplate *template = [self.templateListViewController selectedTemplate];
  if (template == nil) {
    return;
  }
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  [ws selectFile:template.path inFileViewerRootedAtPath:[template.path stringByDeletingLastPathComponent]];
}

- (IBAction)editSelectedTemplate:(id)sender
{
  TPProjectTemplate *template = [self.templateListViewController selectedTemplate];
  if (template == nil) {
    return;
  }

  NSError *error = nil;
  [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:template.path] display:YES error:&error];
  if (error) {
    [NSApp presentError:error];
  }
}

- (IBAction)duplicateSelectedTemplate:(id)sender
{
  TPProjectTemplate *template = [self.templateListViewController selectedTemplate];
  if (template == nil) {
    return;
  }
  
  NSString *source = template.path;
  NSString *name   = [NSString stringWithFormat:@"%@_copy", template.name];
  NSString *dest   = [[source stringByDeletingLastPathComponent] stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"tpt"]];
  
  NSFileManager *fm = [NSFileManager defaultManager];
  NSInteger counter = 0;
  while ([fm fileExistsAtPath:dest]) {
    name = [NSString stringWithFormat:@"%@_copy_%d", template.name, counter];
    dest = [[source stringByDeletingLastPathComponent] stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"tpt"]];
    counter++;
  }
  
  NSError *error = nil;
  [fm copyItemAtPath:source toPath:dest error:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }
  
  // update info.plist
  NSString *infoPath = [dest stringByAppendingPathComponent:@"info.plist"];
  NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:infoPath];
  [info setValue:name forKey:@"name"];
  [info writeToFile:infoPath atomically:YES];
  
  [self.templateListViewController refreshList];
}

- (IBAction)deleteSelectedTemplate:(id)sender
{
  TPProjectTemplate *template = [self.templateListViewController selectedTemplate];
  if (template == nil) {
    return;
  }
  
  NSAlert *alert = [NSAlert alertWithMessageText:@"Delete Template?"
                                   defaultButton:@"Cancel"
                                 alternateButton:@"Delete"
                                     otherButton:nil
                       informativeTextWithFormat:@"Are you sure you want to delete template '%@'? If you delete it, it will be moved to the trash.", template.name];
  
  [alert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(deleteTemplateAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
  
}

- (void) deleteTemplateAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  
  [NSApp endSheet:alert.window];
  [alert.window orderOut:self];
  
  if (returnCode == NSAlertDefaultReturn) {
    return;
  }
  
  TPProjectTemplate *template = [self.templateListViewController selectedTemplate];
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSArray *urls = [NSArray arrayWithObject:[NSURL fileURLWithPath:template.path]];
  [ws recycleURLs:urls completionHandler:^(NSDictionary *newURLs, NSError *error) {
    [self.templateListViewController refreshList];
  }];
  
}




@end