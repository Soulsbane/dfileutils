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
		if(fileName_.exists())
		{
			remove(fileName_);
		}
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

	string getTempDir()
	{
		return tempDir();
	}

	string getFileName()
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
	import std.stdio : writeln;
	writeln(file.getTempDir);
	writeln(file.getFileName);
	writeln(file.isOpen);
}
