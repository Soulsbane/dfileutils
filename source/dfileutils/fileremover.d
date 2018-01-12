/**
	Keeps a list of files that will be removed on the objects destruction.
*/
module dfileutils.fileremover;

import std.algorithm;
import std.file;

struct FileRemover
{
	~this()
	{
		removeAll();
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
}

unittest
{
	FileRemover remover;

	remover.add("/a/fake/directory");
	remover.add("/media/data");
	remover.add("/another/fake/dir");
}
