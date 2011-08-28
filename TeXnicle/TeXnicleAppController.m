//
//  TeXnicleAppController.m
//  TeXnicle
//
//  Created by hewitson on 26/5/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TeXnicleAppController.h"
#import "externs.h"
#import "PrefsWindowController.h"
#import "NSArray+Color.h"
#import "ConsoleController.h"
#import "StartupScreenController.h"
#import "TeXProjectDocument.h"
#import "ProjectItemEntity.h"
#import "TeXFileEntity.h"
#import "MABSupportFolder.h"
#import "TPEngineManager.h"

NSString * const TEDocumentTemplates = @"TEDocumentTemplates";
NSString * const TEUserCommands = @"TEUserCommands";


NSString * const TPGSPath = @"TPGSPath";
NSString * const TPPDFLatexPath = @"TPPDFLatexPath";
NSString * const TPLatexPath = @"TPLatexPath";
NSString * const TPDvipsPath = @"TPDvipsPath";
NSString * const TPBibTeXPath = @"TPBibTeXPath";
NSString * const TPPS2PDFPath = @"TPPS2PDFPath";


NSString * const TPShouldRunPS2PDF = @"TPShouldRunPS2PDF";
NSString * const TPNRunsPDFLatex = @"TPNRunsPDFLatex";
NSString * const BibTeXDuringTypeset = @"BibTeXDuringTypeset";
NSString * const TPDefaultEngineName = @"TPDefaultEngineName";
NSString * const OpenConsoleOnTypeset = @"OpenConsoleOnTypeset";


NSString * const TPTrashFiles = @"TPTrashFiles";
NSString * const TPTrashDocumentFileWhenTrashing = @"TPTrashDocumentFileWhenTrashing";
NSString * const TPSpellCheckerLanguage = @"TPSpellCheckerLanguage";

NSString * const TPConsoleDisplayLevel = @"TPConsoleDisplayLevel";

NSString * const TPFileItemTextStorageChangedNotification = @"TPFileItemTextStorageChangedNotification";

NSString * const TECursorPositionDidChangeNotification = @"TECursorPositionDidChangeNotification";
NSString * const TELineWrapStyle = @"TELineWrapStyle";
NSString * const TELineLength = @"TELineLength";
NSString * const TEInsertSpacesForTabs = @"TEInsertSpacesForTabs";
NSString * const TENumSpacesForTab = @"TENumSpacesForTab";
NSString * const TEShowLineNumbers = @"TEShowLineNumbers";
NSString * const TEShowCodeFolders = @"TEShowCodeFolders";
NSString * const TEHighlightCurrentLine = @"TEHighlightCurrentLine";
NSString * const TPSaveOnCompile = @"TPSaveOnCompile";

NSString * const TEDocumentBackgroundColor = @"TEDocumentBackgroundColor";
NSString * const TEDocumentFont = @"TEDocumentFont";
NSString * const TESyntaxTextColor = @"TESyntaxTextColor";

NSString * const TEConsoleFont = @"TEConsoleFont";

// comment
NSString * const TESyntaxCommentsColor = @"TESyntaxCommentsColor";
NSString * const TESyntaxColorComments = @"TESyntaxColorComments";

// special chars
NSString * const TESyntaxSpecialCharsColor = @"TESyntaxSpecialCharsColor";
NSString * const TESyntaxColorSpecialChars = @"TESyntaxColorSpecialChars";

// commands
NSString * const TESyntaxCommandColor = @"TESyntaxCommandColor";
NSString * const TESyntaxColorCommand = @"TESyntaxColorCommand";

// arguments
NSString * const TESyntaxArgumentsColor = @"TESyntaxArgumentsColor";
NSString * const TESyntaxColorArguments = @"TESyntaxColorArguments";


NSString * const TPPaletteRowHeight = @"TPPaletteRowHeight";
NSString * const TPLibraryRowHeight = @"TPLibraryRowHeight";


@implementation TeXnicleAppController

+ (void) initialize
{
  // create a dictionary for the ‘factory’ defaults
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
  // load library
  NSString *libpath = [[NSBundle mainBundle] pathForResource:@"Library" ofType:@"plist"];
	NSDictionary *library = [NSMutableDictionary dictionaryWithContentsOfFile:libpath];
	[defaultValues setObject:library forKey:@"Library"];
  
  // get the templates from the app bundle plist
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Templates" ofType:@"plist"];
	NSDictionary *templateDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	NSMutableArray *templates = [NSMutableArray array];
	for (NSDictionary *dict in [templateDictionary valueForKey:@"Templates"]) {
		[templates addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
	}
	[defaultValues setObject:templates forKey:TEDocumentTemplates];

  // user commands
  [defaultValues setObject:[NSMutableArray array] forKey:TEUserCommands];
  
	// Document settings	
	[defaultValues setValue:[NSNumber numberWithInt:TPHardWrap] forKey:TELineWrapStyle];
	[defaultValues setValue:[NSNumber numberWithInt:80] forKey:TELineLength];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEInsertSpacesForTabs];
	[defaultValues setValue:[NSNumber numberWithInt:2] forKey:TENumSpacesForTab];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEShowLineNumbers];
	[defaultValues setValue:[NSNumber numberWithBool:NO] forKey:TEShowCodeFolders];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TEHighlightCurrentLine];
  
  [defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TPSaveOnCompile];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:OpenConsoleOnTypeset];

  // console
  [defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSFont userFixedPitchFontOfSize:12.0]] forKey:TEConsoleFont];  
	
	//--- colors for syntax highlighting
	
  // default text
  [defaultValues setObject:[NSArchiver archivedDataWithRootObject:[NSFont systemFontOfSize:14.0]] forKey:TEDocumentFont];  
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor blackColor]] forKey:TESyntaxTextColor];
  [defaultValues setValue:[NSArray arrayWithColor:[NSColor whiteColor]] forKey:TEDocumentBackgroundColor];
  
  // comments
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor lightGrayColor]] forKey:TESyntaxCommentsColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorComments];
	
  // special chars
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:50.0/255.0 green:35.0/255.0 blue:1.0 alpha:1.0]] forKey:TESyntaxSpecialCharsColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorSpecialChars];
  
  // commands
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:25.0/255.0 green:20.0/255.0 blue:150.0/255.0 alpha:1.0]] forKey:TESyntaxCommandColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorCommand];
  
  // arguments
	[defaultValues setValue:[NSArray arrayWithColor:[NSColor colorWithDeviceRed:0.0/255.0 green:100.0/255.0 blue:185.0/255.0 alpha:1.0]] forKey:TESyntaxArgumentsColor];
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:TESyntaxColorArguments];
	
  //---------- Paths
	// GS
	[defaultValues setObject:@"/usr/local/bin/gs" forKey:TPGSPath];
	
	// PDFLatex
	[defaultValues setObject:@"/usr/texbin/pdflatex" forKey:TPPDFLatexPath];
	
	// Latex
	[defaultValues setObject:@"/usr/texbin/latex" forKey:TPLatexPath];
	
	// dvips
	[defaultValues setObject:@"/usr/texbin/dvips" forKey:TPDvipsPath];
	
	// BibTeX path
	[defaultValues setObject:@"/usr/texbin/bibtex" forKey:TPBibTeXPath];
	
	// ps2pdf path
	[defaultValues setObject:@"" forKey:TPPS2PDFPath];
  
	// Number of times to run pdflatex
	[defaultValues setValue:[NSNumber numberWithUnsignedInt:3] forKey:TPNRunsPDFLatex];
	
	// BibTeX during typeset
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:BibTeXDuringTypeset];
	
	// Run ps2pdf after typeset
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TPShouldRunPS2PDF];
  
  // Default engine name
  [defaultValues setObject:@"pdflatex" forKey:TPDefaultEngineName];
  
	// --------- Trash
	NSArray *files = [NSArray arrayWithObjects:@"aux", @"log", @"bbl", @"out", nil];
	[defaultValues setObject:files forKey:TPTrashFiles];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TPTrashDocumentFileWhenTrashing];
  
	//---------- Console settings
	[defaultValues setValue:[NSNumber numberWithInt:0] forKey:TPConsoleDisplayLevel];	
	
	
	//---------- Hidden settings
	[defaultValues setValue:@"" forKey:TPSpellCheckerLanguage];
  [defaultValues setValue:[NSNumber numberWithFloat:15.0] forKey:TPPaletteRowHeight];
  [defaultValues setValue:[NSNumber numberWithFloat:25.0] forKey:TPLibraryRowHeight];
  
  // register the defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];	
	[[NSUserDefaults standardUserDefaults] synchronize];
  

}


- (id)init
{
  self = [super init];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	// store the language
	NSString *language = [[NSSpellChecker sharedSpellChecker] language];	
	[[NSUserDefaults standardUserDefaults] setValue:language forKey:TPSpellCheckerLanguage];
	[[NSUserDefaults standardUserDefaults] synchronize];
  //	NSLog(@"Stored language to defaults: %@", language);
	
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSError *error = nil;
	if ([[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:filename]
																																						 display:YES
																																							 error:&error]) {
		return YES;
	}
	
	if (error) {
		[NSApp presentError:error];
	}
	
	return NO;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	id controller = [self startupScreen];
	NSArray *recentURLs = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
	for (NSURL *url in recentURLs) {
    if (![[url pathExtension] isEqualToString:@"engine"]) {
      NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:[[url path] lastPathComponent]
                                                                     forKey:@"path"];
      [dict setObject:url forKey:@"url"];
      [[controller recentFiles] addObject:dict];
    }
	}
  
	if ([[[NSDocumentController sharedDocumentController] documents] count]==0) {
		[self showStartupScreen:self];
	}
  
  [self checkVersion];
  [TPEngineManager installEngines];
}

- (void) checkVersion
{
  NSError *error = nil;
  NSString *html = @"http://www.bobsoft-mac.de/resources/TeXnicle/latestversion.txt";
  NSURL *url = [NSURL URLWithString:html];
  NSString *latest = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
  
  NSArray *parts = [latest componentsSeparatedByString:@" "];
  CGFloat latestVersion = [[parts objectAtIndex:0] floatValue];
  CGFloat latestBuild = [[parts objectAtIndex:1] floatValue];
  
//  NSLog(@"Latest ver %f, build %f", latestVersion, latestBuild);
  
  // get values from main bundle
  
	NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
  CGFloat currentBuild = [[dict valueForKey:@"CFBundleVersion"] floatValue];
  CGFloat currentVersion = [[dict valueForKey:@"CFBundleShortVersionString"] floatValue];
  
//  NSLog(@"Current %f, %f", currentVersion, currentBuild);
  
  if (latestVersion > currentVersion || latestBuild > currentBuild) {
    NSAlert *alert = [NSAlert alertWithMessageText:@"New version available"
                                     defaultButton:@"Download Now"
                                   alternateButton:@"Download Later"
                                       otherButton:nil
                         informativeTextWithFormat:@"Version %0.1f build %0.1f of TeXnicle is available for download", latestVersion, latestBuild];
    NSInteger result = [alert runModal];
    if (result == NSAlertDefaultReturn) {
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.bobsoft-mac.de"]];
    } else if (result == NSAlertAlternateReturn) {
      // do nothing
    }
  }
}

                      
- (id)startupScreen
{
	if (!startupScreenController) {
		startupScreenController = [[StartupScreenController alloc] init];
	}
	return startupScreenController;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return NO;
}

- (IBAction)showPreferences:(id)sender
{
	[[PrefsWindowController sharedPrefsWindowController] showWindow:nil];
}

- (IBAction) showConsole:(id)sender
{
	ConsoleController *consoleController = [ConsoleController sharedConsoleController];
	[consoleController showWindow:self];
	[[consoleController window] makeKeyAndOrderFront:self];
}

- (IBAction) showStartupScreen:(id)sender
{
	if (!startupScreenController) {
		startupScreenController = [[StartupScreenController alloc] init];
	}
	
	[startupScreenController displayWindow:self];
	//	[startupScreenController showWindow:self];
	//	[[startupScreenController window] makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark Document Control 

- (IBAction) newEmptyProject:(id)sender
{
  id doc = [TeXProjectDocument newTeXnicleProject];
  
	if (doc) {
		[doc saveDocument:self];
	}
}


- (IBAction) newLaTeXFile:(id)sender
{
	
	NSError *error = nil;
  
	id doc = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"TeX Document" error:&error];
	if (error) {
		[NSApp presentError:error];
		return;
	}
	
	[[NSDocumentController sharedDocumentController] addDocument:doc];
	[doc makeWindowControllers];
	[doc showWindows];
	
	if ([[self startupScreen] isOpen]) {
		[[self startupScreen] displayOrCloseWindow:self];
	}

}

#pragma mark -
#pragma mark Menu Control 

- (void)menuNeedsUpdate:(NSMenu *)menu
{
//  NSLog(@"Menu update");
	id doc = nil;
	if ([NSDocumentController sharedDocumentController]) {
		doc = [[NSDocumentController sharedDocumentController] currentDocument];
	}
	
	if ([[menu title] isEqual:@"Project"]) {
		
		
		//	// Close and Close Tab
		//	NSMenuItem *closeMenuItem = [menu itemWithTag:100];
		//	NSMenuItem *closeTabMenuItem = [menu itemWithTag:110];
		//	
		//
		//		NSLog(@"Current window %@", [[NSApplication sharedApplication] keyWindow]);
		//	
		
		// New Folder menu item
		NSMenuItem *newFolderItem = [menu itemWithTag:10];
		if (newFolderItem) {
			[newFolderItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewFolder)]) {
					if ([doc performSelector:@selector(canAddNewFolder)]) {
						[newFolderItem setEnabled:YES];
					}
				}
			}
		}
		
		// New File menu item
		NSMenuItem *newFileItem = [menu itemWithTag:15];
		if (newFileItem) {
			[newFileItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewFile)]) {
					if ([doc performSelector:@selector(canAddNewFile)]) {
						[newFileItem setEnabled:YES];
					}
				}
			}
		}
		
		// New TeX File menu item
		NSMenuItem *newTeXFileMenu = [menu itemWithTag:20];
		if (newTeXFileMenu) {
			[newTeXFileMenu setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewTeXFile)]) {
					if ([doc performSelector:@selector(canAddNewTeXFile)]) {
						[newTeXFileMenu setEnabled:YES];
					}
				}
			}
		}
		
		// Delete menu item
		NSMenuItem *deleteMenu = [menu itemWithTag:30];
		if (deleteMenu) {
			[deleteMenu setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canRemove)]) {
					if ([doc canRemove]) {
						[deleteMenu setEnabled:YES];
						[deleteMenu setTitle:[NSString stringWithFormat:@"Remove \u201c%@\u201d", [doc performSelector:@selector(nameOfSelectedProjectItem)]]];
					}
				}
			}
		}
		
		// Open project folder
		NSMenuItem *openProjectFolderItem = [menu itemWithTag:21];
		if (openProjectFolderItem) {
			[openProjectFolderItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(project)]) {
					[openProjectFolderItem setEnabled:YES];
				}
			}
		}
		
		// Open project TOC
		NSMenuItem *projectTocItem = [menu itemWithTag:22];
		if (projectTocItem) {
			[projectTocItem setEnabled:NO];
			if (doc) {
				if ([doc isKindOfClass:[TeXProjectDocument class]]) {
					[projectTocItem setEnabled:YES];
				}
			}
		}
		
		// Set Main File item
		NSMenuItem *setMainItem = [menu itemWithTag:25];
		if (setMainItem) {
			[setMainItem setTitle:@"Set Main File"];
			[setMainItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(getSelectedItems)]) {
					NSArray *items = [doc performSelector:@selector(getSelectedItems)];
					if ([items count] == 1) {
						ProjectItemEntity *item = [items objectAtIndex:0];
						if ([item isKindOfClass:[TeXFileEntity class]]) {
							if ([[item valueForKey:@"extension"] isEqual:@"tex"]) {
								[setMainItem setEnabled:YES];
								if ([[doc project] valueForKey:@"mainFile"] == item) {
									[setMainItem setTitle:[NSString stringWithFormat:@"Unset \u201c%@\u201d As Main File", [item valueForKey:@"name"]]];
								} else {
									[setMainItem setTitle:[NSString stringWithFormat:@"Set \u201c%@\u201d As Main File", [item valueForKey:@"name"]]];
								}
							}
						}
					}
				}
			}
		}
		
		// Jump to main file
		NSMenuItem *jumpToMainItem = [menu itemWithTag:26];
		if (jumpToMainItem) {
			[jumpToMainItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(project)]) {
					if ([[doc project] valueForKey:@"mainFile"]) {
						[jumpToMainItem setEnabled:YES];
					}
				}
			}
		}
		
		// Add existing file...
		NSMenuItem *addExistingFileItem = [menu itemWithTag:27];
		if (addExistingFileItem) {
			[addExistingFileItem setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canAddNewTeXFile)]) {
					[addExistingFileItem setEnabled:[doc canAddNewTeXFile]];
				}
			}
		}
		
		// Typeset menuitem
		NSMenuItem *item = [menu itemWithTag:40];
		if (item) {
			[item setEnabled:NO];
			[item setTitle:@"Typeset Project"];
			if (doc) {
				if ([doc respondsToSelector:@selector(canTypeset)]) {
          BOOL result = [doc canTypeset];
					[item setEnabled:result];
					NSString *mainFile = [[[doc project] valueForKey:@"mainFile"] valueForKey:@"shortName"];
					if (mainFile) {
						[item setTitle:[NSString stringWithFormat:@"Typeset \u201c%@\u201d", mainFile]];
					}
				}
			}
		}
		
		// Typeset and view menu item
		item = [menu itemWithTag:50];
		if (item) {
			[item setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canTypeset)]) {
					[item setEnabled:[doc canTypeset]];
				}
			}
		}
		
		// View PDF
		item = [menu itemWithTag:60];
		if (item) {
			[item setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canViewPDF)]) {
					[item setEnabled:[doc canViewPDF]];
				}
			}
		}
		
		// BibTeX
		item = [menu itemWithTag:70];
		if (item) {
			[item setTitle:@"BibTeX Project"];
			[item setEnabled:NO];
			if (doc) {
				if ([doc respondsToSelector:@selector(canBibTeX)]) {
					[item setEnabled:[doc canBibTeX]];
					NSString *mainFile = [[[doc project] valueForKey:@"mainFile"] valueForKey:@"shortName"];
					if (mainFile) {
						[item setTitle:[NSString stringWithFormat:@"BibTeX \u201c%@\u201d", mainFile]];
					}
				}
			}
		}
	} // End if Project menu
	
	// View menu
	if ([[menu title] isEqual:@"View"]) {
		NSMenuItem *showHidden = [menu itemWithTag:100];
		if (showHidden) {
			id fr = [[NSApp keyWindow] firstResponder];
			if ([fr respondsToSelector:@selector(showsInvisibleCharacters)]) {
				[showHidden setEnabled:[fr showsInvisibleCharacters]]; 
				[showHidden setState:[fr showsInvisibleCharacters]]; 
			} else {
				[showHidden setEnabled:NO]; 
				[showHidden setState:0]; 
			}
		}		
		
	} // end view menu
	
}


@end
