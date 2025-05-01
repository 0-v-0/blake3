module blake3.binding;

extern (C) pure nothrow @nogc:

// Copied from BLAKE3/c/blake3.h

enum BLAKE3_VERSION_STRING = "1.8.2";
enum BLAKE3_KEY_LEN = 32,
	BLAKE3_OUT_LEN = 32,
	BLAKE3_BLOCK_LEN = 64,
	BLAKE3_CHUNK_LEN = 1024,
	BLAKE3_MAX_DEPTH = 54;

// This struct is a private implementation detail. It has to be here because
// it's part of blake3_hasher below.
struct blake3_chunk_state {
	uint[8] cv;
	ulong chunk_counter;
	ubyte[BLAKE3_BLOCK_LEN] buf;
	ubyte buf_len;
	ubyte blocks_compressed;
	ubyte flags;
}

struct blake3_hasher {
	uint[8] key;
	blake3_chunk_state chunk;
	ubyte cv_stack_len;
	// The stack size is MAX_DEPTH + 1 because we do lazy merging. For example,
	// with 7 chunks, we have 3 entries in the stack. Adding an 8th chunk
	// requires a 4th entry, rather than merging everything down to 1, because we
	// don't know whether more input is coming. This is different from how the
	// reference implementation does things.
	ubyte[(BLAKE3_MAX_DEPTH + 1) * BLAKE3_OUT_LEN] cv_stack;
}

const(char)* blake3_version() @safe;
void blake3_hasher_init(blake3_hasher* self);
void blake3_hasher_init_keyed(
	blake3_hasher* self,
	ref const(ubyte)[BLAKE3_KEY_LEN] key);
void blake3_hasher_init_derive_key(blake3_hasher* self, const(char)* context);
void blake3_hasher_init_derive_key_raw(
	blake3_hasher* self,
	const(void)* context,
	size_t context_len);
void blake3_hasher_update(
	blake3_hasher* self,
	const(void)* input,
	size_t input_len);
version (BLAKE3_USE_TBB) {
	void blake3_hasher_update_tbb(
		blake3_hasher* self,
		const(void)* input,
		size_t input_len);
}
void blake3_hasher_finalize(
	const(blake3_hasher)* self,
	ubyte* out_,
	size_t out_len);
void blake3_hasher_finalize_seek(
	const(blake3_hasher)* self,
	ulong seek,
	ubyte* out_,
	size_t out_len);
void blake3_hasher_reset(blake3_hasher* self);
