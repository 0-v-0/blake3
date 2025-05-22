module blake3;

version (Have_dynamic) {
	import blake3.binding;
	import dynamic;

	__gshared mixin dynamicBinding!(blake3.binding) libblake3;

	shared static this() {
		version (Windows)
			libblake3.loadBinding("libblake3");
		else
			libblake3.loadBinding("libblake3.so");
	}
} else
	import blake3.binding;

@safe:

alias Hasher = blake3_hasher;

/// The hash value of empty input.
enum ubyte[32] emptyHash = cast(const(ubyte)[])x"af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262";

/// A BLAKE3 hasher.
auto BLAKE3() @trusted {
	Hasher hasher = void;
	blake3_hasher_init(&hasher);
	return hasher;
}

/// A BLAKE3 hasher with a key.
auto BLAKE3(in ubyte[BLAKE3_KEY_LEN] key) @trusted {
	Hasher hasher = void;
	blake3_hasher_init_keyed(&hasher, key);
	return hasher;
}

/// A BLAKE3 hasher with a derived key.
auto BLAKE3(const char* context) @trusted {
	Hasher hasher = void;
	blake3_hasher_init_derive_key(&hasher, context);
	return hasher;
}

/// A BLAKE3 hasher with a raw derived key.
auto BLAKE3(const(void)* context, size_t contextLen) @trusted {
	Hasher hasher = void;
	blake3_hasher_init_derive_key_raw(&hasher, context, contextLen);
	return hasher;
}

/// Update the hasher with data.
void put(ref Hasher hasher, in void[] data) @trusted pure nothrow @nogc {
	blake3_hasher_update(&hasher, data.ptr, data.length);
}

/// Finalize the hasher and return the hash value.
ubyte[L] finish(size_t L = BLAKE3_OUT_LEN)(const ref Hasher hasher) @trusted
if (L > 0 && L < 4096) {
	ubyte[L] output = void;
	blake3_hasher_finalize(&hasher, output.ptr, L);
	return output;
}

/// ditto
ubyte[L] finish(size_t L = BLAKE3_OUT_LEN)(const ref Hasher hasher, ulong seek) @trusted
if (L > 0 && L < 4096) {
	ubyte[L] output = void;
	blake3_hasher_finalize_seek(&hasher, seek, output.ptr, L);
	return output;
}

/// ditto
void finish(const ref Hasher hasher, ubyte[] output) @trusted {
	blake3_hasher_finalize(&hasher, output.ptr, output.length);
}

/// ditto
void finish(const ref Hasher hasher, ubyte[] output, ulong seek) @trusted {
	blake3_hasher_finalize_seek(&hasher, seek, output.ptr, output.length);
}

/// Reset the hasher to its initial state.
void reset(ref Hasher hasher) @trusted pure nothrow @nogc {
	blake3_hasher_reset(&hasher);
}

/// Compute the BLAKE3 hash value of data.
ubyte[L] blake3Of(size_t L = BLAKE3_OUT_LEN)(in void[] data)
if (L > 0 && L < 4096) {
	auto hasher = BLAKE3();
	hasher.put(data);
	return hasher.finish!L();
}

///
unittest {
	assert(blake3Of([]) == emptyHash);
	assert(blake3Of("Hello world!") == x"793c10bc0b28c378330d39edace7260af9da81d603b8ffede2706a21eda893f4");
}

ubyte[L] blake3Of(size_t L = 32)(in void[] data, in ubyte[32] key) {
	auto hasher = BLAKE3(key);
	hasher.put(data);
	return hasher.finish!L();
}
