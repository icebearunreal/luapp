local is_windows = package.config:sub(1,1) == "\\"
local home = is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")
local install_path = home .. (is_windows and "\\.lpp" or "/.lpp")

local function write_file(path, content)
local f = io.open(path, "w")
if f then f:write(content); f:close() else print("Error writing: " .. path) end
    end

    -- 1. create Directory for install
    os.execute(is_windows and ('mkdir "' .. install_path .. '" 2>nul') or ('mkdir -p "' .. install_path .. '"'))

    -- 2. THE TRANSPILER (logic.lua)
    local transpiler_logic = [===[
        local M = {}
        local install_path = "]===] .. install_path:gsub("\\", "\\\\") .. [===["

        function M.load_features()
        local f = io.open(install_path .. "/features.json", "r")
        if not f then return {} end
            local content = f:read("*all")
            f:close()
            local rules = {}
            for pat, rep in content:gmatch('"pattern":%s*"(.-)".-"replace":%s*"(.-)"') do
                table.insert(rules, {pat = pat, rep = rep})
                end
                return rules
                end

                function M.run(code)
                local features = M.load_features()
                local strings = {}

                -- Protect Strings
                code = code:gsub('"(.-)"', function(s)
                table.insert(strings, '"' .. s .. '"')
                return "___LPP_STR_" .. #strings .. "___"
                end)
                code = code:gsub("'(.-)'", function(s)
                table.insert(strings, "'" .. s .. "'")
                return "___LPP_STR_" .. #strings .. "___"
                end)

                -- Apply JSON Rules
                for _, rule in ipairs(features) do
                    code = code:gsub(rule.pat, rule.rep)
                    end

                    -- Core Class Logic
                    code = code:gsub("class%s+(%w+)", function(name)
                    return name .. " = {}; " .. name .. ".__index = " .. name .. "; function " .. name .. ".new(o) o = o or {}; setmetatable(o, " .. name .. "); return o end"
                    end)

                    -- Restore Strings
                    for i, s in ipairs(strings) do
                        code = code:gsub("___LPP_STR_" .. i .. "___", s, 1)
                        end

                        return "local ffi = require('ffi')\n" .. code
                        end
                        return M
        ]===] -- do not question my lexer/parser or whatever this is called, punni01.

        -- 3. THE ENGINE (luapp_engine.lua)
        local engine_code = [===[
            local install_path = "]===] .. install_path:gsub("\\", "\\\\") .. [===["
            local path_sep = package.config:sub(1,1)
            package.path = install_path .. path_sep .. "?.lua;" .. package.path

            local ffi = require("ffi")
            local transpiler = require("transpiler")

            -- Define Globals for the LPP environment
            _G.ffi = ffi
            _G.std = {
                out = print,
                c = ffi.C,
                gui = {
                    alert = function(title, msg)
                    if ffi.os == "Windows" then
                        ffi.cdef[[int MessageBoxA(void*, const char*, const char*, int);]]
                        ffi.C.MessageBoxA(nil, msg, title, 0)
                        else
                            os.execute(string.format('zenity --info --title="%s" --text="%s" 2>/dev/null || echo "%s"', title, msg, msg))
                            end
                            end
                }
            }

            local target = arg[1] or "main.lpp"
            local f = io.open(target, "r")
            if not f then print("Error: " .. target .. " not found") os.exit(1) end
                local main_code = f:read("*all")
                f:close()

                local transformed = transpiler.run(main_code)
                local func, err = loadstring(transformed, target)
                if not func then
                    print("\27[31mCompiler Error:\27[0m\n" .. err)
                    else
                        setfenv(func, _G)
                        local ok, run_err = pcall(func)
                        if not ok then print("\27[31mRuntime Error:\27[0m " .. run_err) end
                            end
                        ]===] -- cursed. I hate this. i DONT Want to continue maintaining (jk this is the most fun i've ever had)

                        -- 4. write
                        write_file(install_path .. "/transpiler.lua", transpiler_logic)
                        write_file(install_path .. "/luapp_engine.lua", engine_code)

                        -- 5. make executable depending on uh the OS you have
                        local bin_path = install_path .. (is_windows and "\\luapp.bat" or "/luapp")
                        if is_windows then
                            write_file(bin_path, "@echo off\nluajit \"" .. install_path .. "\\luapp_engine.lua\" %*")
                            else
                                write_file(bin_path, "#!/bin/bash\nluajit \"" .. install_path .. "/luapp_engine.lua\" \"$@\"")
                                os.execute("chmod +x \"" .. bin_path .. "\"")
                                end

                                print("Toolchain installed to: " .. install_path)
                                print("Run 'luajit install_lpp.lua' whenever you change your features.json!")
