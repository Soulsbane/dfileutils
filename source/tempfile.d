module dfileutils.tempfile;

import std.file : tempDir, remove, exists;
import std.path : buildNormalizedPath;
import std.uuid : randomUUID;
import std.stdio : writeln, File;
import std.exception : ErrnoException;

struct TempFile
{
	~this()
	{
		remove();
	}

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

	bool remove()
	{
		if(fileName_.exists())
		{
			.remove(fileName_);
		}

		return fileName_.exists;
	}

	string getTempDir() @safe
	{
		return tempDir();
	}

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

	file.create("dfileutils-unittest", ".log");
	writeln(file.getTempDir);
	writeln(file.getFileName);
	writeln(file.isOpen);
}
