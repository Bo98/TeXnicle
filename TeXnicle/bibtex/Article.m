//
//  Article.m
//  TeXnicle
//
//  Created by Martin Hewitson on 22/3/10.
//  Copyright 2010 AEI Hannover . All rights reserved.
//

#import "Article.h"
#import "NSMutableAttributedString+BibFieldDisplay.h"

@implementation Article

@synthesize journal;
@synthesize volume;
@synthesize number;
@synthesize pages;
@synthesize abstractText;

- (id)init
{
	self = [super init];
	
	if (self) {
		[self setJournal:@"Unknown"];
		[self setVolume:@""];
		[self setNumber:@""];
		[self setPages:@""];
		[self setAbstractText:@""];
	}
	
	return self;
}

- (id) initWithDictionary:(NSDictionary*)entryData
{
	self = [super initWithDictionary:entryData];
	
	if (self) {
		
		[self setJournal:@"Unknown"];
		[self setVolume:@""];
		[self setNumber:@""];
		[self setPages:@""];
		[self setAbstractText:@""];
		
		NSString *str = [entryData valueForKey:@"Journal"];
		if (str)
			[self setJournal:str];
		
		str = [entryData valueForKey:@"Volume"];
		if (str)
			[self setVolume:str];
		
		str = [entryData valueForKey:@"Number"];
		if (str)
			[self setNumber:str];
		
		str = [entryData valueForKey:@"Pages"];
		if (str)
			[self setPages:str];
		
		str = [entryData valueForKey:@"Abstract"];
		if (str)
			[self setAbstractText:str];
		
		[self observeKeys];		
	}
	
	return self;
}

- (void) dealloc
{
	[self stopObserving];
	[super dealloc];
}

#pragma mark -
#pragma mark KVO 

- (void)observeKeys
{
	
	for (NSString *key in [self observingKeys]) {
		[self addObserver:self 
					 forKeyPath:key
							options:NSKeyValueObservingOptionNew 
							context:NULL];
	}	
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
											ofObject:(id)object
												change:(NSDictionary *)change 
											 context:(void *)context
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:TPBibliographyChangedNotification object:self];
}

- (void) stopObserving
{
	for (NSString *key in [self observingKeys]) {
		[self removeObserver:self forKeyPath:key];
	}	
}

- (NSArray*) observingKeys
{
	return [[super observingKeys] 
					arrayByAddingObjectsFromArray:[NSArray 
																				 arrayWithObjects:@"journal", @"volume", @"number", @"pages", @"abstractText", nil]];
}

#pragma mark -
#pragma mark Encoding/decoding

- (id)initWithCoder:(NSCoder *)coder
{
//	NSLog(@"InitWithCoder: Article");
	[super initWithCoder:coder];
	journal = [[coder decodeObjectForKey:@"journal"] retain];
	volume = [[coder decodeObjectForKey:@"volume"] retain];
	number = [[coder decodeObjectForKey:@"number"] retain];
	pages = [[coder decodeObjectForKey:@"pages"] retain];
	abstractText = [[coder decodeObjectForKey:@"abstractText"] retain];
	[self observeKeys];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	[coder encodeObject:journal forKey:@"journal"];
	[coder encodeObject:volume forKey:@"volume"];
	[coder encodeObject:number forKey:@"number"];
	[coder encodeObject:pages forKey:@"pages"];
	[coder encodeObject:abstractText forKey:@"abstractText"];
}


- (NSAttributedString*) displayString
{
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithAttributedString:[super displayString]] autorelease];
	
	NSString *vstr = [self journal];
	if (!vstr)
		vstr = @"";
	[str addString:vstr withTag:@"Journal:"];
	
	vstr = [self volume];
	if (!vstr)
		vstr = @"";	
	[str addString:vstr withTag:@"Volume:"];
	
	vstr = [self number];
	if (!vstr)
		vstr = @"";	
	[str addString:vstr withTag:@"Number:"];
	
	vstr = [self pages];
	if (!vstr)
		vstr = @"";	
	[str addString:vstr withTag:@"Pages:"];
	
	vstr = [self abstractText];
	if (!vstr)
		vstr = @"";	
	[str addString:vstr withTag:@"Abstract\n\n"];
	
	return str;
}

- (id)copyWithZone:(NSZone *)zone
{
	Article *copy = [super copyWithZone:zone];
	
	[copy setJournal:[self journal]];
	[copy setVolume:[self volume]];
	[copy setNumber:[self number]];
	[copy setPages:[self pages]];
	[copy setAbstractText:[self abstractText]];
		
	return copy;
}

- (NSString*) bibtexEntry
{
	NSMutableString *str = [NSMutableString stringWithString:@"@article{"];
	
	// add tag
	NSString *vstr = [self tag];
	if (!vstr)
		vstr = @"";
	
	[str appendFormat:@"%@,\n", vstr];
	
	// add author
	vstr = [self author];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tAuthor={%@},\n", vstr];
	
	// add title 
	vstr = [self title];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tTitle={%@},\n", vstr];
	
	// add published
	vstr = [self publishedDate];
	if (!vstr) 
		vstr = @"";
	[str appendFormat:@"\tYear={%@},\n", vstr];
	
	// add journal
	vstr = [self journal];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tJournal={%@},\n", vstr];
	
	// add volume
	vstr = [self volume];
	if (!vstr) 
		vstr = @"";
	[str appendFormat:@"\tVolume={%@},\n", vstr];

	// add number
	vstr = [self number];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tNumber={%@},\n", vstr];

	// add number
	vstr = [self pages];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tPages={%@},\n", vstr];
	
	// add abstract
	vstr = [self abstractText];
	if (!vstr)
		vstr = @"";
	[str appendFormat:@"\tAbstract={%@}", vstr];
	
	[str appendFormat:@"}"];
		
	return [NSString stringWithString:str];
}

- (void) setPropertiesFromEntry:(Article*)anEntry
{
	[super setPropertiesFromEntry:anEntry];
	
	[self setJournal:[anEntry journal]];
	[self setVolume:[anEntry volume]];
	[self setNumber:[anEntry number]];
	[self setPages:[anEntry pages]];
	[self setAbstractText:[anEntry abstractText]];
	
}


@end
