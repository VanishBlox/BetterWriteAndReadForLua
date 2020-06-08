local function ReadFromDisk(fileAdress, mode, linesMode, linesIndex)
    --[[
    Read modes:
    a	Reads all of the content from the file.
    l	Reads a single line from the file.
    L	Reads a single line from the file, but keeps the end of line character(s)
    n	Reads a number from the file. This reads until the end of a valid sequence.
    [number]	Reads [number] characters (bytes) from the file. Does not use quotes.
    lines   goes to a certian line and reads from it
    
    lines mode:
    backward gets you all of the lines before requested line and the line reqeuested
    forward gets you requested line and everything after it
    current only gets you requested line
    all     gives you all of the lines
    ]]
    
    local returnValue;
    local logs = io.open(fileAdress, "r")
    
    if logs ~= nil then
        if mode == nil then
            returnValue = logs:read("a")
        
        elseif mode:lower() == "lines" then
            local temparray = {};
            if ({backward = true, current = true, forward = true, all = true})[linesMode] then
                -- read lines in whichever linesMode is requested
                if linesMode == "backward" then
                    -- read all lines behind current line including current line
                    local index = 1;
                    for line in logs:lines() do
                        index = index + 1
                        table.insert(temparray, line)
                        if index > linesindex then
                            break
                        end
                    end
                elseif linesMode == "current" then
                    -- read current line
                    local index = 1;
                    for line in logs:lines() do
                        if index == linesindex then
                            table.insert(temparray, line)
                            break
                        end
                        index = index + 1
                    end
                elseif linesMode == "forward" then
                    -- read all lines after current line including current line
                    local index = 1;
                    for line in logs:lines() do
                        if index >= linesindex then
                            table.insert(temparray, line)
                        end
                        index = index + 1
                    end
                elseif linesMode == "all" then
                    for line in logs:lines() do
                        table.insert(temparray, line)
                    end
                end
            elseif tonumber(linesMode) then
                -- read with "current" linesMode but number is used to refer to which line it is
                local index = 1;
                for line in logs:lines() do
                    if index == tonumber(linesMode) then
                        table.insert(temparray, line)
                        break
                    end
                    index = index + 1
                end
            else
                -- do first line
                for line in logs:lines() do
                    table.insert(temparray, line)
                    break
                end
            end
            returnValue = temparray
        else
            returnValue = logs:read(mode)
        end
        logs:close()
    end
    
    return returnValue
end

local function WriteToDisk(fileAdress, data, lineindex)
    --[[   
    r	(Default) Open the file read only.
    w	Open the file to write. Overwrites contents or makes a new file.
    a	Append the file. Write to the end or make a new file. Repositioning operations are ignored.
    r+	Open the file in read and write mode. The file must exist.
    w+	Open the file to write. Clears existing contents or makes a new file.
    a+	Append the file with read mode. Write to the end or make a new file. Repositioning operations affect read mode.

    right modes: 
    [number]    if there is no number or number too high then it will append
    CompleteWipeOutOfFile   Deletes everything in the file, makes it blank
    ]]
    if data ~= nil then
        if lineindex == "CompleteWipeOutOfFile" then
            local logs = io.open(fileAdress, "w")
            logs:write("")
            logs:close()
        else
            if lineindex ~= nil and lineindex <= #ReadFromDisk("lines", "all") then
                local OverWriteTable = ReadFromDisk("lines", "all")
                OverWriteTable[lineindex] = data
                
                local logs = io.open(fileAdress, "w")
                for i,v in ipairs(OverWriteTable) do
                    logs:write(v .. "\n")
                end
                logs:close()
            else -- append at end of file
                if ReadFromDisk("a"):sub(-1) ~= "\n"  and ReadFromDisk("a"):len() > 0 then
                    data = "\n" .. data
                end
                
                if data:sub(-1) ~= "\n" then
                    data = data .. "\n"
                end
        
                local logs = io.open(fileAdress, "a") 
                logs:write(data)
                logs:close()
            end
        end
    end
end
