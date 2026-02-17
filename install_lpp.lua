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
-- bunch of prompts that you will face here
if not ask("Install to system?") then os.exit() end

    local home = is_windows and os.getenv("USERPROFILE") or os.getenv("HOME") 
    local install_path = home .. (is_windows and "\\.lpp" or "/.lpp")

    if is_windows then -- detect operating system
        os.execute('mkdir "' .. install_path .. '" 2>nul')
        else
            os.execute('mkdir -p "' .. install_path .. '"') -- else is NOT LInux it is unix. (Linux / MAC) i am NOT a lazy dev
            end
            -- here is the grammar/dictionary/ whatever you want to call it. defines EVERYTHING that's lovely and thats holy
            local engine_code = [[
                local function transpile(code)
                code = code:gsub("//", "--")
                code = code:gsub("([Ll]ink[Tt]o)%s+[\"'](.-)[\"']", function(_, path)
                local mod = path:gsub("%.lpp$", ""):gsub("^/", ""):gsub("/", ".")
                return string.format('%s = require("%s")', mod:match("[^%.]+$"), mod)
                end)
                -- Fixed: Classes are no longer local so they can be exported/imported via LinkTo
                code = code:gsub("class%s+(%w+)", function(className)
                return string.format("%s = {}; %s.__index = %s; function %s.new(o) o = o or {}; setmetatable(o, %s); return o end",
                                     className, className, className, className, className)
                end)
                code = code:gsub("var%s+(%w+):%s*%w+", "local %1")
                code = code:gsub("luapp.out", "print")
                return code
                end

                table.insert(package.loaders or package.searchers, 1, function(modname) 
                local filename = modname:gsub("%.", "/") .. ".lpp"
                local f = io.open(filename, "r")
                if f then
                    local content = f:read("*all")
                    f:close()
                    -- Append 'return ClassName' logic for LinkTo
                    local className = content:match("class%s+(%w+)")
                    local transformed = transpile(content)
                    if className then transformed = transformed .. "\nreturn " .. className end
                        return loadstring(transformed, filename)
                        end
                        return "\n\tno file '" .. filename .. "' (LuaPP Searcher)"
                        end)

                local target = arg[1] or "main.lpp"
                local f = io.open(target, "r")
                if not f then print("Error: Could not find '" .. target .. "'") os.exit(1) end
                    local main_code = f:read("*all")
                    f:close()

                    local func, err = loadstring(transpile(main_code), target)
                    if not func then
                        print("\27[31mCompiler Error:\27[0m\n" .. err)
                        else
                            local ok, run_err = pcall(func)
                            if not ok then print("\27[31mRuntime Error:\27[0m " .. run_err) end
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

                                    if ask("Add to path?") then -- add to path so u can run anywehre NOT TESTED ON 
                                        if is_windows then
                                            os.execute('setx Path "%Path%;' .. install_path .. '"')
                                            else
                                                local shell_rc = os.getenv("HOME") .. (os.getenv("SHELL"):find("zsh") and "/.zshrc" or "/.bashrc")
                                                local f = io.open(shell_rc, "a")
                                                f:write('\nexport PATH="$PATH:' .. install_path .. '"\n')
                                                f:close()
                                                end
                                                print("Installed to: " .. install_path)
                                                end
