/* -*- C -*- */


/* ================================================================ */
/* ================================================================ */
/* ================================================================ */
/*              THE FOLLOWING IS FILLED WITH CMAKE                  */
/* ================================================================ */
/* ================================================================ */
/* ================================================================ */

#ifndef luaconf_cmake_h
#define luaconf_cmake_h

#define LUA_USE_MODULE_AND_LIBRARY 1
#define LUA_USE_DLOPEN 1

#define LUAJIT_USE_READLINE
/* #undef LUAJIT_DISABLE_FFI */
/* #undef LUAJIT_ENABLE_LUA52COMPAT */
/* #undef LUAJIT_DISABLE_JIT */
#define LUAJIT_CPU_SSE2
/* #undef LUAJIT_CPU_NOCMOV */

#endif

/* ================================================================ */
/* ================================================================ */
/* ================================================================ */
/*  THE FOLLOWING IS COPIED VERBATIM FROM LUAJIT-2.0/SRC/LUACONF.H  */
/* ================================================================ */
/* ================================================================ */
/* ================================================================ */


#ifndef luaconf_h
#define luaconf_h

#include <limits.h>
#include <stddef.h>

/* Default path for loading Lua and C modules with require(). */
#if defined(_WIN32)
/*
** In Windows, any exclamation mark ('!') in the path is replaced by the
** path of the directory of the executable file of the current process.
*/
#define LUA_LDIR	"!\\lua\\"
#define LUA_CDIR	"!\\"
#define LUA_PATH_DEFAULT \
  ".\\?.lua;" LUA_LDIR"?.lua;" LUA_LDIR"?\\init.lua;"
#define LUA_CPATH_DEFAULT \
  ".\\?.dll;" LUA_CDIR"?.dll;" LUA_CDIR"loadall.dll"
#else
#define LUA_ROOT	"/usr/local/"
#define LUA_LDIR	LUA_ROOT "share/lua/5.1/"
#define LUA_CDIR	LUA_ROOT "lib/lua/5.1/"
#ifdef LUA_XROOT
#define LUA_JDIR	LUA_XROOT "share/luajit-2.0.0/"
#define LUA_XPATH \
  ";" LUA_XROOT "share/lua/5.1/?.lua;" LUA_XROOT "share/lua/5.1/?/init.lua"
#define LUA_XCPATH	LUA_XROOT "lib/lua/5.1/?.so;"
#else
#define LUA_JDIR	LUA_ROOT "share/luajit-2.0.0/"
#define LUA_XPATH
#define LUA_XCPATH
#endif
#define LUA_PATH_DEFAULT \
  "./?.lua;" LUA_JDIR"?.lua;" LUA_LDIR"?.lua;" LUA_LDIR"?/init.lua" LUA_XPATH
#define LUA_CPATH_DEFAULT \
  "./?.so;" LUA_CDIR"?.so;" LUA_XCPATH LUA_CDIR"loadall.so"
#endif

/* Environment variable names for path overrides and initialization code. */
#define LUA_PATH	"LUA_PATH"
#define LUA_CPATH	"LUA_CPATH"
#define LUA_INIT	"LUA_INIT"

/* Special file system characters. */
#if defined(_WIN32)
#define LUA_DIRSEP	"\\"
#else
#define LUA_DIRSEP	"/"
#endif
#define LUA_PATHSEP	";"
#define LUA_PATH_MARK	"?"
#define LUA_EXECDIR	"!"
#define LUA_IGMARK	"-"
#define LUA_PATH_CONFIG \
  LUA_DIRSEP "\n" LUA_PATHSEP "\n" LUA_PATH_MARK "\n" \
  LUA_EXECDIR "\n" LUA_IGMARK

/* Quoting in error messages. */
#define LUA_QL(x)	"'" x "'"
#define LUA_QS		LUA_QL("%s")

/* Various tunables. */
#define LUAI_MAXSTACK	65500	/* Max. # of stack slots for a thread (<64K). */
#define LUAI_MAXCSTACK	8000	/* Max. # of stack slots for a C func (<10K). */
#define LUAI_GCPAUSE	200	/* Pause GC until memory is at 200%. */
#define LUAI_GCMUL	200	/* Run GC at 200% of allocation speed. */
#define LUA_MAXCAPTURES	32	/* Max. pattern captures. */

/* Compatibility with older library function names. */
#define LUA_COMPAT_MOD		/* OLD: math.mod, NEW: math.fmod */
#define LUA_COMPAT_GFIND	/* OLD: string.gfind, NEW: string.gmatch */

/* Configuration for the frontend (the luajit executable). */
#if defined(luajit_c)
#define LUA_PROGNAME	"luajit"  /* Fallback frontend name. */
#define LUA_PROMPT	"> "	/* Interactive prompt. */
#define LUA_PROMPT2	">> "	/* Continuation prompt. */
#define LUA_MAXINPUT	512	/* Max. input line length. */
#endif

/* Note: changing the following defines breaks the Lua 5.1 ABI. */
#define LUA_INTEGER	ptrdiff_t
#define LUA_IDSIZE	60	/* Size of lua_Debug.short_src. */
/*
** Size of lauxlib and io.* on-stack buffers. Weird workaround to avoid using
** unreasonable amounts of stack space, but still retain ABI compatibility.
** Blame Lua for depending on BUFSIZ in the ABI, blame **** for wrecking it.
*/
#define LUAL_BUFFERSIZE       (BUFSIZ > 16384 ? 8192 : BUFSIZ)

/* The following defines are here only for compatibility with luaconf.h
** from the standard Lua distribution. They must not be changed for LuaJIT.
*/
#define LUA_NUMBER_DOUBLE
#define LUA_NUMBER		double
#define LUAI_UACNUMBER		double
#define LUA_NUMBER_SCAN		"%lf"
#define LUA_NUMBER_FMT		"%.14g"
#define lua_number2str(s, n)	sprintf((s), LUA_NUMBER_FMT, (n))
#define LUAI_MAXNUMBER2STR	32
#define LUA_INTFRMLEN		"l"
#define LUA_INTFRM_T		long

/* Linkage of public API functions. */
#if defined(LUA_BUILD_AS_DLL)
#if defined(LUA_CORE) || defined(LUA_LIB)
#define LUA_API		__declspec(dllexport)
#else
#define LUA_API		__declspec(dllimport)
#endif
#else
#define LUA_API		extern
#endif

#define LUALIB_API	LUA_API

/* Support for internal assertions. */
#if defined(LUA_USE_ASSERT) || defined(LUA_USE_APICHECK)
#include <assert.h>
#endif
#ifdef LUA_USE_ASSERT
#define lua_assert(x)		assert(x)
#endif
#ifdef LUA_USE_APICHECK
#define luai_apicheck(L, o)	{ (void)L; assert(o); }
#else
#define luai_apicheck(L, o)	{ (void)L; }
#endif

#endif

/* ================================================================ */
/* ================================================================ */
/* ================================================================ */
/*              CUSTOM DEFINITIONS FOR TORCH                        */
/* ================================================================ */
/* ================================================================ */
/* ================================================================ */

#ifndef luaconf_cpp_h
# define luaconf_cpp_h
# ifdef __cplusplus
#  define LUA_EXTERNC extern "C"
# else
#  define LUA_EXTERNC extern
# endif
# undef LUA_API
# undef LUALIB_API
# if defined(LUA_BUILD_AS_DLL) && !defined(liblua_STATIC)
#  if defined(liblua_EXPORTS) || defined(liblua_shared_EXPORTS)
#   define LUA_API    LUA_EXTERNC __declspec(dllexport)
#   define LUALIB_API LUA_EXTERNC __declspec(dllexport)
#  else
#   define LUA_API    LUA_EXTERNC __declspec(dllimport)
#   define LUALIB_API LUA_EXTERNC __declspec(dllimport)
#  endif
# else
#  define LUA_API     LUA_EXTERNC
#  define LUALIB_API  LUA_EXTERNC
# endif
#endif

#ifndef luaconf_readline_h
#define luaconf_readline_h

#if defined(LUAJIT_USE_READLINE)
#include <stdio.h>
//#include <readline/readline.h>
//#include <readline/history.h>
#define lua_readline(L,b,p) ((void)L, ((b)=readline(p)) != NULL)
#define lua_saveline(L,idx) \
  if (lua_strlen(L,idx) > 0)  /* non-empty line? */ \
    add_history(lua_tostring(L, idx));  /* add it to history */
#define lua_freeline(L,b) ((void)L, free(b))
#else
#define lua_readline(L,b,p) \
  ((void)L, fputs(p, stdout), fflush(stdout),  /* show prompt */ \
   fgets(b, LUA_MAXINPUT, stdin) != NULL)  /* get line */
#define lua_saveline(L,idx) { (void)L; (void)idx; }
#define lua_freeline(L,b) { (void)L; (void)b; }
#endif

#endif

#ifndef luaconf_path_h
# define luaconf_path_h
# undef LUA_LDIR
# undef LUA_CDIR
# undef LUA_PATH_DEFAULT
# undef LUA_CPATH_DEFAULT
#if !defined(LUA_ANSI) && defined(_WIN32)
#define LUA_WIN
#endif
LUA_API const char *lua_path_default();
LUA_API const char *lua_cpath_default();
LUA_API const char *lua_executable_dir(const char *argv0);
# define LUA_PATH_DEFAULT lua_path_default()
# define LUA_CPATH_DEFAULT lua_cpath_default()
# define HAVE_LUA_EXECUTABLE_DIR 1
# define LUA_LDIR LUA_EXECDIR \
    "/../share/torch/lua/"
# define LUA_CDIR LUA_EXECDIR \
    "/../lib/torch/lua/"
# define LUA_PATH_DEFAULT_STATIC  \
   "./?.lua;" \
    LUA_LDIR"?.lua;" \
    LUA_LDIR"?/init.lua;" \
    LUA_CDIR"?.lua;" \
    LUA_CDIR"?/init.lua"

# if LUA_USE_MODULE_AND_LIBRARY
#  define LUA_CPATH_DEFAULT_STATIC \
    "./?.so;" \
    "./?.dylib;" \
    LUA_CDIR"?.so;" \
    LUA_CDIR"?.dylib;" \
    LUA_CDIR"loadall.so" \
    LUA_CDIR"loadall.dylib"
# elif defined(LUA_WIN)
#  define LUA_CPATH_DEFAULT_STATIC \
    "./?.so;" \
    LUA_EXECDIR "/?.so;" \
    LUA_CDIR"?.so;" \
    LUA_CDIR"loadall.so"
# else
#  define LUA_CPATH_DEFAULT_STATIC \
    "./?.so;" \
    LUA_CDIR"?.so;" \
    LUA_CDIR"loadall.so"
# endif
#endif
