
local lfs = require("lfs")  -- LuaFileSystem is needed for directory traversal

-- Function to check if a file exists in the current directory
local function file_exists_in_dir(filename, dir)
    for file in lfs.dir(dir) do
        if file == filename then
            return true
        end
    end
    return false
end

-- Function to traverse from script's directory upwards to home directory
local function find_file_upwards(start_dir)
    local home_dir = os.getenv("HOME") or os.getenv("USERPROFILE")  -- Get the home directory
    local filename = "venv"
    local current_dir = start_dir

    repeat
        if file_exists_in_dir(filename, current_dir) then
            return current_dir .. "/" .. filename  -- Return the full path to the file
        end

        -- Move one directory up
        current_dir = current_dir:match("(.*)/")
    until current_dir == nil or current_dir == home_dir

    return nil  -- File not found
end

-- Get the directory where the script is located
local script_dir = lfs.currentdir()


