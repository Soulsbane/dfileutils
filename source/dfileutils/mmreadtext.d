module dfileutils.mmreadtext;

import std.range : array, front;
import std.algorithm : min;
import std.mmfile : MmFile;
import std.utf : decodeFront;

struct MmTextRange {
public:
	this(const string filename)
	{
		file_ = new MmFile(filename);
	}

	auto front()
	{
		auto data = nextSlice;
		return data.decodeFront;
	}

	void popFront()
	{
		auto data = nextSlice;
		size_t bytes;

		data.decodeFront(bytes);
		fileOffset_ += bytes;
	}

	bool empty()
	{
		return getCurrentLength() <= 0;
	}

	string getText()
	{
		return cast(string)file_[];
	}

private:
	ulong getCurrentLength() const
	{
		return file_.length - fileOffset_;
	}

	string nextSlice() @property
	{
		auto offset = min(4, getCurrentLength);
		return cast(string)file_[fileOffset_ .. fileOffset_ + offset];
	}

private:
	ulong  fileOffset_;
	MmFile file_;
}

string readMmText(const string fileName)
{
	auto f = new MmFile(fileName);
	immutable string data = cast(string) f[];

	return data;
}

unittest
{
	import std.algorithm.comparison : equal;

	auto expected = import("../" ~ __FILE__);
	auto result = MmTextRange(__FILE__);

	import std.stdio;
	/*foreach(dat; result)
	{
		write(dat);
	}*/
	assert(equal(result, expected));
	assert(equal(readMmText(__FILE__), expected));
}
