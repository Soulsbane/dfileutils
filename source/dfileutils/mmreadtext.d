module dfileutils.mmreadtext;

import std.range : array, front;
import std.algorithm : min;
import std.mmfile : MmFile;
import std.utf : decodeFront;

@safe:
struct MmText {
public:
	this(string filename) @trusted
	{
		file_ = new MmFile(filename);
	}

	dchar front()
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
		return ulLength <= 0;
	}

private:
	ulong ulLength() const @trusted
	{
		return file_.length - fileOffset_;
	}

	private string nextSlice() @property @trusted
	{
		auto offset = min(4, ulLength);
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

	assert(equal(result, expected));
}
