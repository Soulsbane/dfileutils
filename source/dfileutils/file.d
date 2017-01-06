module dfileutils.file;

import std.file : exists, write, remove;
import std.string : startsWith;
import std.path;
import std.typecons;

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
		import std.path : baseName;
		if(fileName.baseName.startsWith("."))
		{
			return true;
		}
	}

	version(Windows)
	{
		import win32.winnt : getAttributes, FILE_ATTRIBUTE_HIDDEN;

		if (getAttributes(fileName) & FILE_ATTRIBUTE_HIDDEN)
		{
			return true;
		}
	}

	return false;
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
