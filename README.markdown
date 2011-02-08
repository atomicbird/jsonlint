# jsonlint

## Introduction

jsonlint is a command-line tool for Mac OS X that can be used to parse, validate, and convert JSON text files.

It makes use of a slightly modified version of Jonathan Wight's TouchJSON for JSON processing: <https://github.com/atomicbird/TouchJSON>.

## Getting jsonlint

Since jsonlint includes TouchJSON as a git submodule, you'll need to clone recursively to get all the necessary code:

	git clone --recursive git://github.com/atomicbird/jsonlint.git
	
## License

jsonlint is licensed under the MIT license.

## Usage

jsonlint reads from standard input and writes to standard output. Its simplest usage echoes the incoming JSON to stdout if the JSON is valid. If not, it prints hopefully-useful error message to stderr.

	% jsonlint < ex5.json
	{"menu":{"items":[{"id":"Open"},{"id":"OpenNew","label":"Open New"},null,{"id":"ZoomIn","label":"Zoom In"},{"id":"ZoomOut","label":"Zoom Out"},{"id":"OriginalView","label":"Original View"},null,{"id":"Quality"},{"id":"Pause"},{"id":"Mute"},null,{"id":"Find","label":"Find..."},{"id":"FindAgain","label":"Find Again"},{"id":"Copy"},{"id":"CopyAgain","label":"Copy Again"},{"id":"CopySVG","label":"Copy SVG"},{"id":"ViewSVG","label":"View SVG"},{"id":"ViewSource","label":"View Source"},{"id":"SaveAs","label":"Save As"},null,{"id":"Help"},{"id":"About","label":"About Adobe CVG Viewer..."}],"header":"SVG Viewer"}}

	% jsonlint < fail17.json
	["Illegal backslash escape: 017"]

## Arguments

	-q
	--quiet
> Don't echo the input to the output.

	-f
	--formatted
> Format the output for easier reading by humans.

	-p
	--plist
> Print the output in property list format rather than as JSON.

	-a
	--force-array
> Force the incoming JSON to be treated as an array. If an array is not found, an error is printed and 1 is returned, even if the incoming data is valid non-array JSON.

	-d
	--force-dict
> Force the incoming JSON to be treated as dictionary. If a dictionary is not found, an error is printed and 1 is returned, even if the incoming data is valid non-dictionary JSON.

	-e
	--encoding-search
> Run through possible string encodings in the hope of finding one that matches incoming data. Useful if you're dealing with a server API that includes, for example, ISO-Latin-1 or MacOSRoman in JSON. This may result in successfully parsing JSON that violates RFC 4627 (http://www.ietf.org/rfc/rfc4627.txt), but sometimes such abominations are necessary.

## Return codes

Returns 0 if the incoming JSON is valid, 1 if it is not.

## Examples

### Formatted output

	jsonlint --format < ex1.json
	{
	  "glossary" : {
		  "title" : "example glossary",
		  "GlossDiv" : {
			  "title" : "S",
			  "GlossList" : {
				  "GlossEntry" : {
					  "Abbrev" : "ISO 8879:1986",
					  "SortAs" : "SGML",
					  "GlossTerm" : "Standard Generalized Markup Language",
					  "GlossDef" : {
						  "GlossSeeAlso" : [
							  "GML",
							  "XML"
							  ],
						  "para" : "A meta-markup language, used to create markup languages such as DocBook."
						  },
					  "GlossSee" : "markup",
					  "ID" : "SGML",
					  "Acronym" : "SGML"
					  }
				  }
			  }
		  }
	  }

### Property list output
	jsonlint --format --plist < ex1.json
	{
		glossary =     {
			GlossDiv =         {
				GlossList =             {
					GlossEntry =                 {
						Abbrev = "ISO 8879:1986";
						Acronym = SGML;
						GlossDef =                     {
							GlossSeeAlso =                         (
								GML,
								XML
							);
							para = "A meta-markup language, used to create markup languages such as DocBook.";
						};
						GlossSee = markup;
						GlossTerm = "Standard Generalized Markup Language";
						ID = SGML;
						SortAs = SGML;
					};
				};
				title = S;
			};
			title = "example glossary";
		};
	}

### Using jsonlint with other tools

Any command-line tool that writes to standard output can be trivially used with jsonlint, for example:

	curl http://search.twitter.com/search.json?q=foo | jsonlint -p
