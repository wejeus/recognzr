//
//  Torch.h
//

#import <UIKit/UIKit.h>

#import "lua.h"
#import "TH/TH.h"
#import "luaT.h"
#import "lualib.h"
#import "lauxlib.h"

LUA_API int luaopen_libtorch(lua_State *L);
LUA_API int luaopen_libnn(lua_State *L);
LUA_API int luaopen_libnnx(lua_State *L);
LUA_API int luaopen_libimage(lua_State *L);

@interface Torch : NSObject {
    lua_State *L;
}

- (id) init;
- (int) performClassification:(NSMutableArray *) binaryImage;
- (NSMutableArray *) getDebugPrediction:(NSMutableArray *) binaryImage;

@end 
