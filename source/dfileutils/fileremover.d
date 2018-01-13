/**
	Keeps a list of files that will be removed on the objects destruction.
*/
module dfileutils.fileremover;

import std.algorithm;
import std.file;
import std.typecons;

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

	void removeAll()
	{
		import dfileutils.file : removeFileIfExists;
		files_.each!(a => a.removeFileIfExists());
	}

	void add(const string fileName)
	{
		files_ ~= fileName;
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
}
