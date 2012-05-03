//
//  externs.h
//  TeXnicle
//
//  Created by Martin Hewitson on 10/11/09.
//  Copyright 2009 bobsoft. All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

// preferences

#define LargeTextWidth  1e7
#define LargeTextHeight 1e7

typedef enum {
	TPConsoleDisplayAll,
	TPConsoleDisplayTeXnicle,
	TPConsoleDisplayErrors
} TPConsoleDisplay;

typedef enum {
	TPHardWrap,
	TPSoftWrap,
	TPNoWrap
} TPWrapStyle;

extern NSString * const TEDocumentTemplates;

// command completion
extern NSString * const TEUserCommands;
extern NSString * const TERefCommands;
extern NSString * const TECiteCommands;
extern NSString * const TEBeginCommands;
extern NSString * const TEFileCommands;

extern NSString * const TEAutomaticallyShowCommandCompletionList;
extern NSString * const TEAutomaticallyShowCiteCompletionList;
extern NSString * const TEAutomaticallyShowRefCompletionList;
extern NSString * const TEAutomaticallyShowFileCompletionList;
extern NSString * const TEAutomaticallyShowBeginCompletionList;

extern NSString * const TEAutomaticallyAddEndToBeginStatement;

extern NSString * const TPCheckSyntax;
extern NSString * const TPCheckSyntaxErrors;
extern NSString * const TPChkTeXpath;

extern NSString * const TECursorPositionDidChangeNotification;
extern NSString * const TELineWrapStyle;
extern NSString * const TELineLength;
extern NSString * const TEInsertSpacesForTabs;
extern NSString * const TENumSpacesForTab;
extern NSString * const TEShowLineNumbers;
extern NSString * const TEShowCodeFolders;
extern NSString * const TEHighlightCurrentLine;
extern NSString * const TEHighlightCurrentLineColor;
extern NSString * const TEHighlightMatchingWords;
extern NSString * const TEHighlightMatchingWordsColor;
extern NSString * const TPSaveOnCompile;

extern NSString * const TEDocumentBackgroundColor;
extern NSString * const TESyntaxTextColor;
extern NSString * const TEDocumentFont;

extern NSString * const TEConsoleFont;

// comment
extern NSString * const TESyntaxCommentsColor;
extern NSString * const TESyntaxCommentsL2Color;
extern NSString * const TESyntaxCommentsL3Color;
extern NSString * const TESyntaxColorComments;
extern NSString * const TESyntaxColorCommentsL2;
extern NSString * const TESyntaxColorCommentsL3;
extern NSString * const TESyntaxColorMultilineArguments;

// special chars
extern NSString * const TESyntaxSpecialCharsColor;
extern NSString * const TESyntaxColorSpecialChars;

// command
extern NSString * const TESyntaxCommandColor;
extern NSString * const TESyntaxColorCommand;

// arguments
extern NSString * const TESyntaxArgumentsColor;
extern NSString * const TESyntaxColorArguments;

extern NSString * const TPGSPath;
extern NSString * const TPPDFLatexPath;
extern NSString * const TPLatexPath;
extern NSString * const TPDvipsPath;
extern NSString * const TPBibTeXPath;
extern NSString * const TPPS2PDFPath;

extern NSString * const TPDefaultEngineName;
extern NSString * const TPNRunsPDFLatex;
extern NSString * const BibTeXDuringTypeset;
extern NSString * const TPShouldRunPS2PDF;
extern NSString * const OpenConsoleOnTypeset;

extern NSString * const TPTrashFiles;
extern NSString * const TPTrashDocumentFileWhenTrashing;
extern NSString * const TPConsoleDisplayLevel;
extern NSString * const TPSpellCheckerLanguage;

extern NSString * const TPDefaultEncoding;

// Notifications
extern NSString * const TPSyntaxColorsChangedNotification;
extern NSString * const TPFileItemTextStorageChangedNotification;


// String constants
extern NSString * const TPDocumentWasRenamed;
extern NSString * const TPTreeSelectionDidChange;
extern NSString * const TableViewNodeType;
extern NSString * const OutlineViewNodeType;

// Settings
extern NSString * const TPPaletteRowHeight;
extern NSString * const TPLibraryRowHeight;

// Supported File Types (array of dictionaries)
extern NSString * const TPSupportedFileTypes;


