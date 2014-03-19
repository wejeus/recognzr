//
//  Torch.m
//

#import "Torch.h"

@interface Torch()

- (void) require:(NSString *)file;

@end

@implementation Torch {

//    put requre here??
}

static NSString *appPath;

- (id) init
{
    self = [super init];
    
    if (self) {
        appPath = [[NSBundle mainBundle] resourcePath];
        
        
        // initialize Lua stack
        lua_executable_dir("./lua");
        L = lua_open();
        luaL_openlibs(L);
        
        // Update LUA_PATH in order for 'require' to work within lua scripts
        NSString* luaPackagePath = [NSString stringWithFormat:@"package.path='/?.lua;%@/framework/lua/?.lua;'.. package.path", appPath];
        if (luaL_dostring(L, [luaPackagePath UTF8String]) != 0) {
            NSLog(@"error (updating LUA_PATH): %s", lua_tostring(L, -1));
        }
        
        luaopen_libtorch(L);
        [self require:@"/framework/lua/torch/init.lua"];
        
        luaopen_libnn(L);
        [self require:@"/framework/lua/nn/init.lua"];
        
        //    luaopen_libnnx(L);
        //    [self require:@"/framework/lua/nnx/init.lua"];
        
        luaopen_libimage(L);
        [self require:@"/framework/lua/image/init.lua"];
        
        // Make helpers available to Lua
        lua_pushcfunction(L, lua_getAppPath);
        lua_setglobal(L, "getAppPath");
        
        // Lua code that contains the neural network classifier
        [self require:@"/digits.lua"];    
    }
    
    return self;
}

// Runs a lua file relative to rootpath
- (void)require:(NSString *)file
{
    NSString *modulePath = [appPath stringByAppendingString:file];
    NSLog(@"loading module: %@\n", modulePath);

    int ret = luaL_dofile(L, [modulePath UTF8String]);
    if (ret != 0) {
        NSLog(@"error: %s", lua_tostring(L, -1));
    }
}

/* Helper method for Lua script to be able to access app resources */
static int lua_getAppPath(lua_State *L) {
    lua_pushstring(L, [appPath UTF8String]);
    return 1; // number of results returnd to Lua
}

// TODO: Maybe we have make sure to clear internal stack here first to prevent threading issues if this object is used in global context?
/* binaryImage should must be of size 32x32 organized as a consecutative one dimensional array */
- (int) performClassification:(NSMutableArray *) binaryImage {

    /* push functions and arguments to be used in call */
    lua_getglobal(L, "classify");
    lua_newtable(L);
    for(int i = 0;i < 1024; i++) {
        lua_pushinteger(L, [[binaryImage objectAtIndex:i] intValue]);
        lua_rawseti(L,-2,i + 1);
    }
    
    /* do the call (1 argument, 1 result) */
    if (lua_pcall(L, 1, 1, 0) != 0)
        NSLog(@"error running function `f': %s", lua_tostring(L, -1));
    
    /* retrieve result */
    if (!lua_isnumber(L, -1))
        NSLog(@"function `f' must return a number");
    
    int ret = lua_tonumber(L, -1);
    lua_pop(L, 1);  /* pop returned value */
    
    NSLog(@"[Torch] classification done.");
    
    return ret;
}

- (NSMutableArray *) getDebugPrediction:(NSMutableArray *) binaryImage {
    
    /* push functions and arguments to be used in call */
    lua_getglobal(L, "getAllData");
    lua_newtable(L);
    for(int i = 0;i < 1024; i++) {
        lua_pushinteger(L, [[binaryImage objectAtIndex:i] intValue]);
        lua_rawseti(L,-2,i + 1);
    }
    
    /* do the call (1 argument, 1 result) */
    if (lua_pcall(L, 1, 1, 0) != 0)
        NSLog(@"error running function `f': %s", lua_tostring(L, -1));
    
    lua_getglobal(L, "debug_output");
    lua_pushnil(L);
    
    NSMutableArray *res = [[NSMutableArray alloc] initWithCapacity:10];
    
    int index = 0;
    while(lua_next(L, -2)) {  // <== here is your mistake
        if(lua_isnumber(L, -1)) {
            double value = (double)lua_tonumber(L, -1);
            [res setObject:[[NSNumber alloc] initWithDouble:value] atIndexedSubscript:index];
        }
        lua_pop(L, 1);
        index++;
    }
    lua_pop(L, 1);
    
    return res;
}

@end
