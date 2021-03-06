/**
	Various functions for working with files.

	Authors:
		Paul Crane
*/
module dfileutils.file;

import std.file;
import std.functional;
import std.stdio;
import std.string;
import std.path;
import std.typecons;
import std.datetime.systime;

version(Windows)
{
	import win32.winnt : setAttributes, getAttributes, FILE_ATTRIBUTE_HIDDEN;
}

/**
	Creates fileName if it doesn't exist.

	Params:
		fileName = Name of the file to create or open.
		defaultData = Data that should be writen after the file is created.

	Returns:
		True if the file was created false otherwise
*/
bool ensureFileExists(const string fileName, const string defaultData = string.init)
{
	if(!fileName.exists)
	{
		import std.stdio : File;
		auto f = File(fileName, "w+");

		if(defaultData != string.init)
		{
			f.write(defaultData);
		}
	}

	return fileName.exists;
}

/**
	Removes fileName if it exists.

 	Params:
 		fileName = Name of the file to remove.

	Returns:
		true if the fileName was removed false otherwise.
*/
bool removeFileIfExists(const string fileName)
{
	if(fileName.exists)
	{
		fileName.remove;
	}

	return !fileName.exists;
}

/**
	Removes the filename and recreates it.

	Params:
		fileName = Name of the file to recreate.
		defaultData = Data that should be writen after the file is created.

	Returns:
		True if the file was created false otherwise
*/
bool recreateFile(const string fileName, const string defaultData = string.init)
{
	removeFileIfExists(fileName);
	return ensureFileExists(fileName, defaultData);
}

/**
	Touches a filename ie its last modified time is changed to current time. If the file doesn't exist it is created.

	Params:
		fileName = Name of the file to touch.

	Returns:
		True if the file was touched false otherwise.
*/
bool touchFile(const string fileName)
{
	immutable auto currentTime = Clock.currTime();

	if(fileName.exists)
	{
		fileName.setTimes(currentTime, currentTime);
	}
	else
	{
		auto f = File(fileName, "w+");

		f.write("");
		fileName.setTimes(currentTime, currentTime);
	}

	return fileName.exists;
}

/**
 	Determines if fileName is hidden.

 	Params:
		fileName = Name of the file to check for hidden status.

	Returns:
		true if the fileName is hidden false otherwise.
*/
bool isFileHidden(const string fileName)
{
	version(linux)
	{
		if(fileName.baseName.startsWith("."))
		{
			return true;
		}
	}

	version(Windows)
	{
		if(getAttributes(fileName) & FILE_ATTRIBUTE_HIDDEN)
		{
			return true;
		}
	}

	return false;
}

/**
	Creates a hidden file.

 	Params:
		fileName = Name of the file to create.

	Returns:
		true if the fileName was created false otherwise.
*/
bool createHiddenFile(const string fileName)
{
	version(linux)
	{
		immutable string hiddenFileName = buildNormalizedPath(fileName.dirName, "." ~ fileName.baseName);
		auto f = File(hiddenFileName, "w+");

		return hiddenFileName.exists;
	}

	version(Windows)
	{
		auto f = File(fileName, "w+");
		auto attributes = getAttributes(fileName) & FILE_ATTRIBUTE_HIDDEN;

		setAttributes(fileName, attributes | FILE_ATTRIBUTE_HIDDEN);
		return fileName.exists;
	}
}

/**
	Removes lines from a file using a starting and ending line number.

	Params:
		fileName = The name of the file to remove the line from.
		startLine = The line to start with. Must be greater than 0.
		finishLine = The last line to remove.
*/
void removeLines(const string fileName, const ulong startLine, const ulong finishLine)
{
	if(fileName.exists)
	{
		immutable auto lines = readText(fileName).splitLines();

		if(startLine > 0)
		{
			if(lines.length < startLine + finishLine)
			{
				throw new Exception("Can't delete lines past the end of file!");
			}
			else
			{
				auto f = File(fileName, "w");

				foreach (ulong currentLine, line; lines)
				{
					if(startLine > currentLine || currentLine >= startLine + finishLine)
					{
						f.writeln(line);
					}
				}
			}
		}
	}
	else
	{
		throw new FileException("File not found!");
	}
}

/**
	Removes the  specified line(s) from the file.

	Params:
		predicate = The operation used to compare the line text to.
		fileName = The name of the file to remove the line from.
		lineText = The text to search for and remove.
		amount = The number of line matches to remove.
*/
void removeLines(alias predicate = "a == b")(const string fileName, const string lineText, size_t amount = 0)
{
	if(fileName.exists)
	{
		alias compareFunc = binaryFun!predicate;

		immutable auto lines = readText(fileName).splitLines();
		auto f = File(fileName, "w");
		size_t foundCount;

		foreach(ulong currentLine, line; lines)
		{
			if(compareFunc(line, lineText) && (amount != foundCount || amount == 0))
			{
				++foundCount;
			}
			else
			{
				f.writeln(line);
			}
		}
	}
	else
	{
		throw new FileException("File not found!");
	}
}

unittest
{
	immutable string testData = "
		From time to time
		The clouds give rest
		To the moon-beholders.

		Over the wintry
		forest, winds howl in rage
		with no leaves to blow.

		The lamp once out
		Cool stars enter
		The window frame.

		In the cicada's cry
		In the cicada's cry
		No sign can foretell
		How soon it must die.
	";

	import dfileutils.tempfile;

	TempFile file;

	immutable bool created = file.create("dfileutils.file.unittest", ".log");
	immutable string tempFileName = file.getFileName();

	file.write(testData);
	file.close(); // So data gets written.

	auto lines = readText(tempFileName);
	immutable size_t unmodifiedLength = lines.splitLines.length;

	removeLines(tempFileName, "\t\tIn the cicada's cry");
	lines = readText(tempFileName);

	assert(lines.splitLines.length == (unmodifiedLength - 2));
}

/**
	Convenience function for removeLines that only removes one occurance of lineText.

	Params:
		fileName = The name of the file to remove the line from.
		lineText = The text to search for and remove.
*/
void removeLine(const string fileName, const string lineText)
{
	removeLines(fileName, lineText, 1);
}

///
unittest
{
	immutable string fileName = "unittest-ensure-test.txt";

	assert(fileName.ensureFileExists);
	assert(fileName.removeFileIfExists);

	assert(fileName.ensureFileExists("data to write"));
	assert(fileName.removeFileIfExists);

	immutable string hiddenFile = ".ahiddenfile";

	assert(hiddenFile.ensureFileExists);
	assert(hiddenFile.isFileHidden);
	assert(hiddenFile.removeFileIfExists);

	immutable string nonHiddenFile = "aNonHiddenfile";

	assert(nonHiddenFile.ensureFileExists);
	assert(!nonHiddenFile.isFileHidden);
	assert(nonHiddenFile.removeFileIfExists);
}
