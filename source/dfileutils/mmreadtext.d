module dfileutils.mmreadtext;

import std.range : array, front;
import std.algorithm : min;
import std.mmfile : MmFile;
import std.utf : decodeFront;

@safe:
struct MmText {
public:
	this(const string filename) @trusted
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

private:
	ulong getCurrentLength() const @trusted
	{
		return file_.length - fileOffset_;
	}

	string nextSlice() @property @trusted
	{
		auto offset = min(4, getCurrentLength);
		return cast(string)file_[fileOffset_ .. fileOffset_ + offset];
	}

private:
	ulong  fileOffset_;
	MmFile file_;
}

unittest
{
	import std.algorithm.comparison : equal;

	auto expected = import("../" ~ __FILE__);
	auto result = MmText(__FILE__);

	/*import std.stdio;
	foreach(dat; result)
	{
		write(dat);
	}*/
	assert(equal(result, expected));
}
