module blake3;

version (Have_dynamic) {
	import blake3.binding;
	import dynamic;

	__gshared mixin dynamicBinding!(blake3.binding) libblake3;

	shared static this() {
		version (Windows)
			libblake3.loadBinding(["libblake3"]);
		else
			libblake3.loadBinding(["libblake3.so"]);
	}
} else
	public import blake3.binding;

@safe:

/// The hash value of empty input.
enum ubyte[32] emptyHash = cast(const(ubyte)[])x"af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262";

/// A BLAKE3 hasher.
auto BLAKE3() @trusted {
	blake3_hasher hasher = void;
	blake3_hasher_init(&hasher);
	return hasher;
}

/// A BLAKE3 hasher with a key.
auto BLAKE3(in ubyte[BLAKE3_KEY_LEN] key) @trusted {
	blake3_hasher hasher = void;
	blake3_hasher_init_keyed(&hasher, key);
	return hasher;
}

/// A BLAKE3 hasher with a derived key.
auto BLAKE3(const char* context) @trusted {
	blake3_hasher hasher = void;
	blake3_hasher_init_derive_key(&hasher, context);
	return hasher;
}

/// A BLAKE3 hasher with a raw derived key.
auto BLAKE3(const(void)* context, size_t context_len) @trusted {
	blake3_hasher hasher = void;
	blake3_hasher_init_derive_key_raw(&hasher, context, context_len);
	return hasher;
}

/// Update the hasher with data.
void put(ref blake3_hasher hasher, in void[] data) @trusted {
	blake3_hasher_update(&hasher, data.ptr, data.length);
}

/// Finalize the hasher and return the hash value.
ubyte[L] finish(size_t L = BLAKE3_OUT_LEN)(ref blake3_hasher hasher) @trusted
if (L > 0 && L < 4096) {
	ubyte[L] output = void;
	blake3_hasher_finalize(&hasher, output.ptr, L);
	return output;
}

/// ditto
ubyte[L] finish(size_t L = BLAKE3_OUT_LEN)(ref blake3_hasher hasher, ulong seek) @trusted
if (L > 0 && L < 4096) {
	ubyte[L] output = void;
	blake3_hasher_finalize_seek(&hasher, seek, output.ptr, L);
	return output;
}

/// Compute the BLAKE3 hash value of data.
ubyte[L] blake3Of(size_t L = BLAKE3_OUT_LEN)(in void[] data)
if (L > 0 && L < 4096) {
	auto hasher = BLAKE3();
	hasher.put(data);
	return hasher.finish!L();
}

unittest {
	assert(blake3Of([]) == emptyHash);
	assert(blake3Of("Hello world!") == x"793c10bc0b28c378330d39edace7260af9da81d603b8ffede2706a21eda893f4");
}
