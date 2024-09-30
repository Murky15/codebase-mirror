#ifndef BASE_CONTEXT_H
#define BASE_CONTEXT_H

// @note: Build options

#ifndef ENABLE_ASSERT
# define ENABLE_ASSERT 0
#endif

// @note: Compilers

#if defined(__clang__)
# define COMPILER_CLANG 1
#elif defined(__GNUC__)
# define COMPILER_GCC 1
#elif defined(_MSC_VER)
# define COMPILER_CL 1
#elif defined(__TINYC__)
# define COMPILER_TCC 1
#else
# error "This compiler is not supported!"
#endif

#define LLVM_LIKE_COMPILER COMPILER_CLANG || COMPILER_GCC || COMPILER_TCC

// @note: Operating systems

#if LLVM_LIKE_COMPILER
# if defined(__FreeBSD__) || defined(__OpenBSD__)
#  define OS_BSD 1
#  define OS_UNIX_LIKE 1
# elif defined(__EMSCRIPTEN__)
#  define OS_EMSCRIPTEN 1
# elif defined(__gnu_linux__) || defined(__linux__)
#  define OS_LINUX 1
#  define OS_UNIX_LIKE 1
# elif defined(__APPLE__) && defined(__MACH__)
#  define OS_MAC 1
#  define OS_UNIX_LIKE 1 // Because mac is "unique"
# elif defined(__unix__) || defined(__unix)
#  define OS_UNIX_LIKE 1
# elif defined(_WIN64) || defined(_WIN32)
#  define OS_WINDOWS 1
# else
#  error "This operating system is not supported!"
# endif
#elif COMPILER_CL
# if defined(_WIN64) || defined(_WIN32)
#  define OS_WINDOWS 1
# else
#  error "How are you using msvc"
# endif
#endif

// @note: Architectures

#if defined(__arm__) || defined(_M_ARM)
# define ARCH_ARM32 1
#elif defined(__aarch64__) || defined(_M_ARM64)
# define ARCH_ARM64 1
#elif defined(__i386__) || defined(_M_IX86)
# define ARCH_X86 1
#elif defined(__amd64__) || defined(_M_AMD64)
# define ARCH_X64 1
#elif defined(__riscv)
# define ARCH_RISCV 1
#endif

// @note: Lang

#if defined(__cplusplus)
# define LANG_CPP 1
#else
# define LANG_C 1
#endif

// @note: Zero resulting macros

#ifndef COMPILER_CLANG
# define COMPILER_CLANG 0
#endif
#ifndef COMPILER_GCC
# define COMPILER_GCC 0
#endif
#ifndef COMPILER_CL
# define COMPILER_CL 0
#endif
#ifndef COMPILER_TCC
# define COMPILER_TCC 0
#endif

#ifndef OS_BSD
# define OS_BSD 0
#endif
#ifndef OS_EMSCRIPTEN
# define OS_EMSCRIPTEN 0
#endif
#ifndef OS_LINUX
# define OS_LINUX 0
#endif
#ifndef OS_MAC
# define OS_MAC 0
#endif
#ifndef OS_UNIX_LIKE
# define OS_UNIX_LIKE 0
#endif
#ifndef OS_WINDOWS
# define OS_WINDOWS 0
#endif

#ifndef ARCH_ARM32
# define ARCH_ARM32 0
#endif
#ifndef ARCH_ARM64
# define ARCH_ARM64 0
#endif
#ifndef ARCH_X86
# define ARCH_X86 0
#endif
#ifndef ARCH_X64
# define ARCH_X64 0
#endif
#ifndef ARCH_RISCV
# define ARCH_RISCV 0
#endif

#ifndef LANG_CPP
# define LANG_CPP 0
#endif
#ifndef LANG_C
# define LANG_C 0
#endif

#undef LLVM_LIKE_COMPILER

typedef unsigned int OS_Type;
enum {
    OS_Null,
    OS_Windows,
    OS_Mac,
    OS_Linux,
    OS_Emscripten,
    OS_Bsd,
    
    OS_Count
};

typedef unsigned int Arch_Type;
enum {
    Arch_Null,
    Arch_Arm32,
    Arch_Arm64,
    Arch_X86,
    Arch_X64,
    Arch_RISCV,
    
    Arch_Count
};

typedef unsigned int Compiler_Type;
enum {
    Compiler_Null,
    Compiler_Clang,
    Compiler_GCC,
    Compiler_CL,
    Compiler_TCC,
    
    Compiler_Count
};

void
ctx_print (void) {
    puts("--- CONTEXT REPORT ---");
    printf("Clang: %d\n", COMPILER_CLANG);
    printf("GCC: %d\n", COMPILER_GCC);
    printf("MSVC: %d\n", COMPILER_CL);
    printf("TCC: %d\n", COMPILER_TCC);
    printf("BSD: %d\n", OS_BSD);
    printf("Emscripten: %d\n", OS_EMSCRIPTEN);
    printf("Linux: %d\n", OS_LINUX);
    printf("Mac: %d\n", OS_MAC);
    printf("Unix-like: %d\n", OS_UNIX_LIKE);
    printf("Windows: %d\n", OS_WINDOWS);
    printf("Arm 32bit: %d\n", ARCH_ARM32);
    printf("Arm 64bit: %d\n", ARCH_ARM64);
    printf("x86: %d\n", ARCH_X86);
    printf("x64: %d\n", ARCH_X64);
    printf("riscv: %d\n", ARCH_RISCV);
    printf("cpp: %d\n", LANG_CPP);
    printf("c: %d\n\n", LANG_C);
}

OS_Type
ctx_get_os (void) {
#if OS_BSD
    return OS_Bsd;
#elif OS_EMSCRIPTEN
    return OS_Emscripten;
#elif OS_LINUX
    return OS_Linux;
#elif OS_MAC
    return OS_Mac;
#elif OS_WINDOWS
    return OS_Windows;
#else 
    return OS_Null;
#endif
}

Arch_Type
ctx_get_arch (void) {
#if ARCH_ARM32
    return Arch_Arm32;
#elif ARCH_ARM64
    return Arch_Arm64;
#elif ARCH_X86
    return Arch_X86;
#elif ARCH_X64
    return Arch_X64;
#elif ARCH_RISCV
    return Arch_RISCV;
#else
    return Arch_Null;
#endif
}

Compiler_Type
ctx_get_compiler (void) {
#if COMPILER_CLANG
    return Compiler_Clang;
#elif COMPILER_GCC
    return Compiler_GCC;
#elif COMPILER_CL
    return Compiler_CL;
#elif COMPILER_TCC
    return Compiler_TCC;
#else 
    return Compiler_Null;
#endif
}

#endif // BASE_CONTEXT_H