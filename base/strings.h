#ifndef BASE_STRINGS_H
#define BASE_STRINGS_H

// @note: Basic string types

typedef struct String8 {
  u8* str;
  u64 len;
} String8;

typedef struct String16 {
  u16* str;
  u64 len;
} String16;

typedef struct String32 {
  u32* str;
  u64 len;
} String32;

// @note: String structure types

typedef struct String8Node {
  String8Node *next;
  String8 string;
} String8Node;

typedef struct String8List {
  String8Node *first;
  String8Node *last;
  u64 num_strings;
  u64 total_len;
}

typedef struct String8Array {
  u64 count;
  String8 *strings;
} String8Array;

// @note: String operation types

typedef struct String8Join {
  String8 pre, sep, post;
} String8Join;

typedef struct Decoded_Codepoint {
  u32 codepoint;
  u32 advance;
} Decoded_Codepoint;

typedef u32 String8_Matchflags;
enum {
  MATCH_CASE_INSENSITIVE = (1 << 0),
  MATCH_RIGHT_SIDE_SLOPPY = (1 << 1),
  MATCH_SLASH_INSENSITIVE = (1 << 2),
};

// @note: Char functions

link b32 char_is_alpha(u8 c);
link b32 char_is_alpha_upper(u8 c);
link b32 char_is_alpha_lower(u8 c);
link b32 char_is_digit(u8 c);
link b32 char_is_symbol(u8 c);
link b32 char_is_control(u8 c);
link b32 char_is_space(u8 c);
link u8  char_to_upper(u8 c);
link u8  char_to_lower(u8 c);
link u8  char_to_forward_slash(u8 c);
link u64 cstr_length(char *cstr);

// @note: String functions

// Constructors
link String8 str8(u8 *str, u64 len);
#define str8_zero() str8(0, 0)
#define str8_cstring(cstr) str8((u8*)cstr, cstr_length(cstr))
#define str8_lit(s) str8((u8*)s, sizeof(s)-1)
link String8 str8_range(u8 *first, u8 *opl);
link String16 str16(u16 *str, u64 len);
link String32 str32(u32 *str, u64 len);

#define str8_expand(s) (int)((s).len), ((s).str)

// Substrings
link String8 str8_sub(String8 string, u64 first, u64 opl);
link String8 str8_skip(String8 string, u64 amount);
link String8 str8_chop(String8 string, u64 amount);
link String8 str8_prefix(String8 string, u64 size);
link String8 str8_postfix(String8 string, u64 size);

// Match
link b32 str8_match(String8 a, String8 b, String8_Matchflags flags);

// Allocation
link String8 str8_push_copy(Arena *arena, String8 string);
link String8 str8_pushfv(Arena *arena, char *fmt, va_list args);
link String8 str8_pushf(Arena *arena, char *fmt, ...);

// String lists
link void str8_list_push_node(String8List *list, String8Node *node);
link void str8_list_push_node_front(String8List *list, String8Node *node);
link void str8_list_push(Arena *arena, String8List *list, String8 string);
link void str8_list_push_front(Arena *arena, String8List *list, String8 string);
link void str8_list_pushf(Arena *arena, String8List *list, char *fmt, ...);
link void str8_list_concat(String8List *base, String8List *to_append);
link String8List str8_split_by_strings(Arena *arena, String8 string, u64 num_splits, String8 *splits);
link String8List str8_split_by_chars(Arena *arena, String8 string, u64 num_splits, char *splits);
link String8 str8_list_join(Arena *arena, String8List list, String8Join *opt_join_params);

// Conversions
link String8Array str8_list_to_array(String8List *list);

// @todo: Unicode conversions

#endif // BASE_STRINGS_H