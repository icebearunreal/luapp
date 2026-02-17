local is_windows = package.config:sub(1,1) == "\\"

local function ask(question)
io.write(question .. " (Y/N): ")
local answer = io.read():lower()
return answer == "y"
end

print([[
    ==========================================
    Hello! Welcome to Lua++ (lpp)
    A project made by icebearunreal
    ==========================================
]])

if not ask("Install to system?") then os.exit() end

    local home = is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")
    local install_path = home .. (is_windows and "\\.lpp" or "/.lpp")

    if is_windows then
        os.execute('mkdir "' .. install_path .. '" 2>nul')
        else
            os.execute('mkdir -p "' .. install_path .. '"')
            end

            -- THE FIXED ENGINE CODE ( I dont know what an engine is btw lmao)
            local engine_code = [[
                local target = arg[1] or "main.lpp"
                if target == "." then target = "main.lpp" end

                    local f = io.open(target, "r")
                    if not f then
                        print("Error: Could not find '" .. target .. "'")
                        os.exit(1)
                        end

                        local code = f:read("*all")
                        f:close()

                        -- === LUA++ SYNTAX ENGINE ===

                        -- 1. comments 
                        code = code:gsub("//", "--") -- C++ / Lua style comments supported now!!!!

                        -- 2. Linkto (Updated to be cleaner) LINKS TO OTHER FILES, NOT TESTED
                        code = code:gsub('linkto%s+"/(.-)%.lpp"', function(path)
                        local name = path:match("([^/]+)$")
                        return string.format('local %s = require("%s")', name, path:gsub("/", "."))
                        end)

                        -- 3. THE ATOMIC CLASS FIX
                        -- i replace 'class Name' with 'local Name = {}; Name.__index = Name;'
                        -- i also add a simple constructor.
                        -- best part is, i NO LONGER add an 'end' here.
                        code = code:gsub("class%s+(%w+)", function(className)
                        return string.format("local %s = {}; %s.__index = %s; function %s.new(o) o = o or {}; setmetatable(o, %s); return o end",
                                             className, className, className, className, className)
                        end)

                        -- 4. strip dancing
                        code = code:gsub("var%s+(%w+):%s*%w+", "local %1")

                        -- 5. std lib
                        code = code:gsub("inpout.output", "print")

                        -- === EXECUTION ===
                        local func, err = loadstring(code)
                        if not func then
                            print("\127[31mCompiler Error:\127[0m")
                            print(err)
                            -- helpful debug to show whatever lua saw (yeah we're riding off the best language in the world)
                            -- print("--- GENERATED CODE ---\n" .. code .. "\n----------------------")
                            else
                                local ok, run_err = pcall(func)
                                if not ok then print("\127[31mRuntime Error:\127[0m " .. run_err) end
                                    end
                                ]]

                                local engine_file_path = install_path .. (is_windows and "\\luapp_engine.lua" or "/luapp_engine.lua")
                                local ef = io.open(engine_file_path, "w")
                                ef:write(engine_code)
                                ef:close()

                                local bin_path = install_path .. (is_windows and "\\luapp.bat" or "/luapp")
                                if is_windows then
                                    local bat = io.open(bin_path, "w")
                                    bat:write("@echo off\nluajit \"" .. engine_file_path .. "\" %*")
                                    bat:close()
                                    else
                                        local sh = io.open(bin_path, "w")
                                        sh:write("#!/bin/bash\nluajit \"" .. engine_file_path .. "\" \"$@\"")
                                        sh:close()
                                        os.execute("chmod +x \"" .. bin_path .. "\"")
                                        end

                                        if ask("Add to path?") then
                                            if is_windows then
                                                os.execute('setx Path "%Path%;' .. install_path .. '"')
                                                else
                                                    local shell_rc = os.getenv("HOME") .. (os.getenv("SHELL"):find("zsh") and "/.zshrc" or "/.bashrc")
                                                    local f = io.open(shell_rc, "a")
                                                    f:write('\nexport PATH="$PATH:' .. install_path .. '"\n')
                                                    f:close()
                                                    end
                                                    print("\n[!] Installed to: " .. install_path)
                                                    print("[!] RESTART YOUR TERMINAL.")
                                                    end
