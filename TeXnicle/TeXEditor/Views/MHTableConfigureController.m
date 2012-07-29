//
//  MHTableConfigureController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 07/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "MHTableConfigureController.h"

@interface MHTableConfigureController ()

@property (unsafe_unretained) IBOutlet NSTextField *numRowsField;
@property (unsafe_unretained) IBOutlet NSTextField *numColsField;

@end

@implementation MHTableConfigureController

- (id)initWithDelegate:(id<MHTableConfigureDelegate>)aDelegate
{
  self = [super initWithWindowNibName:@"MHTableConfigureWindow"];
  if (self) {
    // Initialization code here.
    self.delegate = aDelegate;
  }
  
  return self;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (IBAction)cancelClicked:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(tableConfigureDidCancelConfiguration)]) {
    [self.delegate tableConfigureDidCancelConfiguration];
  }
}

- (IBAction)okClicked:(id)sender
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(tableConfigureDidAcceptConfiguration)]) {
    [self.delegate tableConfigureDidAcceptConfiguration];
  }
}

@end
