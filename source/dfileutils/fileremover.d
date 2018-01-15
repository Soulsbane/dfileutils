/**
	Maintains a list of files that will be removed on the objects destruction.
*/
module dfileutils.fileremover;

import std.algorithm;
import std.file;
import std.typecons;

import dfileutils.file : removeFileIfExists;

/**
	Maintains a list of files that will be removed on the objects destruction.
*/
struct FileRemover
{
	/**

		Params:
			autoRemove = Yes.autoRemove to automatically remove files on objects destruction or No.autoRemove otherwise.

	*/
	this(Flag!"autoRemove" autoRemove) pure nothrow @safe
	{
		autoRemove_ = autoRemove;
	}

	~this()
	{
		if(autoRemove_)
		{
			removeAll();
		}
	}

	/**
		Removes a file that FileRemover is tracking.

		Params:
			fileName = Name of the file to remove.
	*/
	bool remove(const string fileName)
	{
		import darrayutils : remove;
		files_.remove(fileName);

		return fileName.removeFileIfExists();
	}

	/**
		Removes all files that FileRemover is tracking.
	*/
	void removeAll()
	{
		files_.each!(a => a.removeFileIfExists());
		files_ = [];
	}

	/**
		Adds a file that FileRemover will remove automatically.
	*/
	void add(const string fileName) pure nothrow @safe
	{
		files_ ~= fileName;
	}

	/**
		The number of files being tracked for removal.
	*/
	size_t count() pure nothrow @safe
	{
		return files_.length;
	}

private:
	string[] files_;
	Flag!"autoRemove" autoRemove_ = Yes.autoRemove;
}

unittest
{
	FileRemover remover;

	remover.add("/a/fake/directory");
	remover.add("/media/data");
	remover.add("/another/fake/dir");
	assert(remover.count == 3);

	remover.removeAll();
	assert(remover.count == 0);

	remover.add("/a/fake/directory");
	remover.add("/media/data");
	remover.add("/another/fake/dir");
	assert(remover.count == 3);

	remover.remove("/another/fake/dir");
	assert(remover.count == 2);
}
