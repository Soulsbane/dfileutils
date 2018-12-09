/**
	Automatically locks a file before reading/writing to it.
*/
module dfileutils.autolock;

import std.stdio;

struct AutoLockFile
{
	this(string fileName, string mode)
	{
		fileName_ = fileName;
		fileHandle_ = File(fileName, mode);
	}

	bool writeln(S...)(S args)
	{
		bool locked = fileHandle_.tryLock();

		if(locked)
		{
			fileHandle_.writeln(args);
			fileHandle_.unlock();
		}

		return locked;
	}

	File getHandle()
	{
		return fileHandle_;
	}

private:
	File fileHandle_;
	string fileName_;
}

unittest
{
	auto f = AutoLockFile("test.txt", "w");
	f.writeln("This is a test");
}
