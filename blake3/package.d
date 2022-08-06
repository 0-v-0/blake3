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

ubyte[outlen] blake3Of(size_t outlen = BLAKE3_OUT_LEN)(in void[] data) @trusted
if (outlen > 0 && outlen < 4096) {
	ubyte[outlen] output = void;
	blake3_hasher hasher = void;
	blake3_hasher_init(&hasher);
	blake3_hasher_update(&hasher, data.ptr, data.length);

	blake3_hasher_finalize(&hasher, output.ptr, outlen);
	return output;
}

@safe unittest {
	assert(blake3Of([]) == [
			0xaf, 0x13, 0x49, 0xb9, 0xf5, 0xf9, 0xa1, 0xa6, 0xa0, 0x40, 0x4d, 0xea,
			0x36, 0xdc, 0xc9, 0x49, 0x9b, 0xcb, 0x25, 0xc9, 0xad, 0xc1, 0x12, 0xb7,
			0xcc, 0x9a, 0x93, 0xca, 0xe4, 0x1f, 0x32, 0x62
		]);
	assert(blake3Of([1, 2]) == [
			123, 165, 176, 113, 164, 63, 213, 22, 3, 45, 160, 134, 168, 95, 101,
			28, 208, 135, 4, 179, 10, 190, 209, 182, 74, 96, 237, 13, 147, 29, 202,
			81
		]);
}
