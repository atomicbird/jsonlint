//
//  main.m
//  jsonlint
//
//  Created by Tom Harrington on 2/4/10.
//  Copyright 2010 Atomic Bird, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <getopt.h>
#import "CJSONDeserializer.h"
#import "CJSONSerializer.h"

BOOL quiet = NO;
BOOL formatted = NO;
BOOL plist = NO;
BOOL encodingSearch = NO;

/* options descriptor */
static struct option longopts[] = {
	{ "quiet",			no_argument,	NULL,	'q' },
	{ "formatted",		no_argument,	NULL,	'f' },
	{ "plist",			no_argument,	NULL,	'p' },
	{ "force-array",	no_argument,	NULL,	'a' },
	{ "force-dict",		no_argument,	NULL,	'd' },
	{ "encoding-search",	no_argument,	NULL,	'e' },
	{ NULL,				0,				NULL,	0 }
};


typedef enum inputType {
	inputTypeArray,
	inputTypeDict,
	inputTypeAuto
} inputType_t;

inputType_t inputType = inputTypeAuto;

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	int ch;
	
	while ((ch = getopt_long(argc, (char * const *)argv, "adefpq", longopts, NULL)) != -1)
		switch (ch) {
			case 'a':
			{
				inputType = inputTypeArray;
				break;
			}
			case 'd':
			{
				inputType = inputTypeDict;
				break;
			}
			case 'e':
			{
				encodingSearch = YES;
				break;
			}
			case 'f':
			{
				formatted = YES;
				break;
			}
			case 'p':
			{
				plist = YES;
				break;
			}
			case 'q':
			{
				quiet = YES;
				break;
			}
		}
	
	NSFileHandle *standardInput = [NSFileHandle fileHandleWithStandardInput];
	NSData *inputData = [standardInput readDataToEndOfFile];
	
	NSError *deserializeError;
	id json = nil;
	CJSONDeserializer *deserializer = [CJSONDeserializer deserializer];

	NSUInteger legalEncodings[] = { NSUTF8StringEncoding, 0 };
	// Some options in allEncodings are probably unnecessary. On the other hand I would not have expected NSMacOSRomanStringEncoding in JSON, and I've seen it.
	NSUInteger allEncodings[] = { 
		NSUTF8StringEncoding,
		NSNEXTSTEPStringEncoding,
		NSJapaneseEUCStringEncoding,
		NSISOLatin1StringEncoding, 
		NSSymbolStringEncoding, 
		NSNonLossyASCIIStringEncoding, 
		NSShiftJISStringEncoding, 
		NSISOLatin2StringEncoding, 
		NSUnicodeStringEncoding, 
		NSWindowsCP1251StringEncoding, 
		NSWindowsCP1252StringEncoding, 
		NSWindowsCP1253StringEncoding, 
		NSWindowsCP1254StringEncoding, 
		NSWindowsCP1250StringEncoding, 
		NSISO2022JPStringEncoding, 
		NSMacOSRomanStringEncoding, 
		NSUTF16StringEncoding, 
		NSUTF16BigEndianStringEncoding, 
		NSUTF16LittleEndianStringEncoding, 
		NSUTF32StringEncoding, 
		NSUTF32BigEndianStringEncoding, 
		NSUTF32LittleEndianStringEncoding, 
		0 };
	NSUInteger *currentEncoding;
	if (encodingSearch) {
		currentEncoding = allEncodings;
	} else {
		currentEncoding = legalEncodings;
	}
	while ((json == nil) && (*currentEncoding != 0)) {
		deserializeError = nil;
		deserializer.allowedEncoding = *currentEncoding;
		currentEncoding++;

		switch (inputType) {
			case inputTypeArray:
			{
				json = [deserializer deserializeAsArray:inputData error:&deserializeError];
				break;
			}
			case inputTypeDict:
			{
				json = [deserializer deserializeAsDictionary:inputData error:&deserializeError];
				break;
			}
			default:
			{
				json = [deserializer deserialize:inputData error:&deserializeError];
			}
		}
	}
	
	if (json != nil) {
		if (!quiet) {
			if (plist) {
				printf("%s\n", [[json description] UTF8String]);
			} else {
				NSError *serializeError = nil;
				CJSONSerializer *serializer = [CJSONSerializer serializer];
				serializer.format = formatted;
				NSData *jsonData = [serializer serializeObject:json error:&serializeError];
				NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
				printf("%s\n", [jsonString UTF8String]);
				[jsonString release];
			}
		}
	}
	
	if (deserializeError != nil) {
		fprintf(stderr, "%s\n", [[deserializeError localizedDescription] UTF8String]);
	}
	
	[pool drain];
    return (deserializeError != nil);
}
