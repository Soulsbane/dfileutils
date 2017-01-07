/**
	A compile time file extractor.

	Authors:
		Paul Crane
*/
module dfileutils.extractor;

import std.algorithm : map;
import std.array : join;
import std.file : exists, mkdirRecurse;
import std.path : buildNormalizedPath, dirName;
import std.typetuple;
import std.typecons;

import dfileutils.file;

alias OverwriteExtractedFiles = Flag!"OverwriteExtractedFiles";

private string getFilesList(T)(T list)
{
	return "TypeTuple!(" ~ list.map!(a => `"` ~ a ~ `"`).join(",") ~ ")";
}

private template GeneratorFileNames(string[] list)
{
	mixin("private alias GeneratorFileNames = " ~ getFilesList(list)~ ";");
}

/**
	Uses a list of files that will be imported using D's string import functionality. The string import for each files
	will then be written according to the path parameter and the name of the file in the file list.

	Note that you will need to set the string import path useing the -J switch if using DMD or the stringImportPaths
	configuration variable if using DUB.

	Params:
		list = Must be an enum string list of filenames that will be imported and written later using the same name.
		path = The path where the files should be exported to.
		overwrite = Whether to overwrite existing files.

	Examples:
		enum filesList =
		[
			"resty/template.lua",
			"helpers.lua"
		];

		// Each file will be will be created in this format: ./myawesomeapp/resty/template.lua
		extractImportFiles!filesList("myawesomeapp");
*/
void extractImportFiles(alias list, T = string)(const string path, OverwriteExtractedFiles overwrite = OverwriteExtractedFiles.yes)
{
	foreach(name; GeneratorFileNames!(list))
	{
		immutable string filePath = dirName(buildNormalizedPath(path, name));
		immutable string pathWithFileName = buildNormalizedPath(path, name);
		T content;

		static if(is(T : string))
		{
			content = import(name);
		}
		else
		{
			content = cast(T)import(name);
		}

		if(overwrite)
		{
			removeFileIfExists(pathWithFileName);
		}

		if(!filePath.exists)
		{
			path.mkdirRecurse;
		}

		ensureFileExists(pathWithFileName, content);
	}
}
