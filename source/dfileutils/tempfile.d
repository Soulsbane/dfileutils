/**
	A simple object for creating and using a temporary file.

	Authors:
		Paul Crane
*/
module dfileutils.tempfile;

import std.file : tempDir, remove, exists;
import std.path : buildNormalizedPath;
import std.uuid : randomUUID;
import std.stdio : writeln, File;
import std.exception : ErrnoException;

//Creates a temporary file that will be removed on object destruction.
struct TempFile
{
	/// Removes  the temporary file.
	~this()
	{
		remove();
	}

	/**
		Creates a temporary file.

		Params:
			prefix = An additional name to prepend to the filename ahead of the randomUUID.
			extension = The file extension to use.

		Returns:
			True if the file was created false otherwise.
	*/
	bool create(const string prefix, const string extension = string.init)
	{
		fileName_ = buildNormalizedPath(getTempDir(), (prefix ~ "-" ~ randomUUID.toString() ~ extension));

		if(!exists(fileName_))
		{
			try
			{
				handle_ = File(fileName_, "w+");
				return true;
			}
			catch(ErrnoException ex)
			{
				return false;
			}
		}

		return false;
	}

	/**
		Removes the temporary file.

		Returns:
			Whether the file exists.
	*/
	bool remove()
	{
		if(fileName_.exists())
		{
			.remove(fileName_);
		}

		return !fileName_.exists;
	}

	/**
		Returns the path to the users temporary directory.

		Returns:
			The path to the users temporary directory.
	*/
	string getTempDir() @safe
	{
		return tempDir();
	}

	/**
		Returns the name of the temporary file.

		Returns:
			The name of the temporary file.
	*/
	string getFileName() pure @safe
	{
		return fileName_;
	}

private:
	string fileName_;
	File handle_;
	alias handle_ this;
}

unittest
{
	TempFile file;

	immutable bool created = file.create("dfileutils-unittest", ".log");
	assert(created ==  true);
	assert(file.isOpen == true);
	writeln(file.getTempDir);
	writeln(file.getFileName);

	file.writeln("hello world");
	assert(file.remove() == true);
}
