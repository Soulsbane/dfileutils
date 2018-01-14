/**
	Keeps a list of files that will be removed on the objects destruction.
*/
module dfileutils.fileremover;

import std.algorithm;
import std.file;
import std.typecons;

import dfileutils.file : removeFileIfExists;

struct FileRemover
{
	this(Flag!"autoRemove" autoRemove)
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

	bool remove(const string fileName)
	{
		import darrayutils : remove;
		files_.remove(fileName);

		return fileName.removeFileIfExists();
	}

	void removeAll()
	{
		files_.each!(a => a.removeFileIfExists());
		files_ = [];
	}

	void add(const string fileName)
	{
		files_ ~= fileName;
	}

	size_t count()
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
