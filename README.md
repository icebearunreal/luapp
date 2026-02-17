# LUA++

**lua++** is a powerful superset of **Lua** featuring native classes, type hinting, and seamless low-level integration. It is designed to provide the structure of modern languages while retaining the legendary speed of the LuaJIT runtime.



> *"C++ is to C what **Lua++** is to Lua."*

Of course, I love Lua, but sometimes I wish I could have... **more!**

---

###  Key Features

| FEATURE | DESCRIPTION |
| :--- | :--- |
| ** Native C Support** | Run raw C code directly within your program via integrated FFI. Extremely cracked performance—born as a joke, evolved into a powerhouse. |
| **Classes** | Robust Object-Oriented Programming. No more manually messing with metatables; just define your class and go. |
| **Static Types** | Optional type safety. Catch logic errors before they happen by defining variable types explicitly. |
| **Smart Linking** | Superior modularity. Use `LinkTo "mathutils/example.lpp"` to handle dependencies more cleanly than standard `require()`. |



---

###  Evolution Path

Soon, I'll deviate from the lovely Lua syntax. Although we'll still have **backward compatibility**, we'll walk in a "TypeScript-esque" direction to bring modern dev-tooling to the Lua ecosystem.

---

### ⌨️ Implementation Preview

```lua
// Modern Class Definition
class Player
    var hp: number = 100

// Direct C Integration
run_c[[
    typedef struct { int x, y; } Point;
    int getpid(void);
]]

LinkTo "utils/vector.lpp"
