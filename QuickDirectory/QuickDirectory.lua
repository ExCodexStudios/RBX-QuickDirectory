--- @class QuickDirectory
--- This class is designed to contain directories to Modules/Instances objects that you can easily access with the name of the Module/Instance object.

local QuickDirectory = {};
QuickDirectory.ClassName = "QuickDirectory";

local Dependencies: Folder = script.Parent:FindFirstChild("Dependencies");

---@module Packages.Promise
local Promise: any = Dependencies and Dependencies:FindFirstChild("Promise") or nil;
if not Promise then
    warn(QuickDirectory._ConvertOut("Missing dependency 'evaera/promise'"));
end

--[=[
    @prop _DirBin Dictionary<T>
    @within QuickDirectory
    @private
    The bin of all directories known to QuickDirectory.
]=]

QuickDirectory._DirBin = {};

--[=[
    This method yields the current thread until it finds the directory or times out after 30 seconds.
    @within QuickDirectory
    @yields
    @param dirName string -- The directory name to find the Module/Instance object.
    @param timeOut number -- The duration in seconds to timeOut if no directory is found.
    @return T? -- Returns the Module/Instance object or nil if the yield timed out
]=]
function QuickDirectory.YieldTillDirectory<T>(dirName: string,timeOut: number?) : T
    if timeOut and typeof(timeOut) ~= "number" then
        error(QuickDirectory._ConvertOut(":YieldTillDirectory() invalid timeOut, type number expected"),3);
    end
    local startTime: number = DateTime.now().UnixTimestamp;
    repeat task.wait(0.2) until QuickDirectory.DirBin[dirName] or timeOut and (DateTime.now().UnixTimestamp - startTime) >= timeOut;
    if not QuickDirectory.DirBin[dirName] then
        warn(QuickDirectory._ConvertOut(":YieldTillDirectory() Could not get directory with name '"..dirName.."'"));
    end
    return QuickDirectory.DirBin[dirName];
end

--[=[
    This method returns a Promise which will resolve to the Module/Instance if it's found but will reject after 30s.
    @within QuickDirectory
    @param dirName string -- The directory name to find the Module/Instance object.
    @return Promise<T> -- Resolves to the Module/Instance object
]=]
function QuickDirectory.PromiseDirectory<T>(dirName: string) : T
    if QuickDirectory.DirBin[dirName] then
        return Promise.resolve(QuickDirectory.DirBin[dirName]);
    end
    return Promise.new(function(resolve,reject,onCancel)
        local startTime: number = DateTime.now().UnixTimestamp;
        repeat
            if QuickDirectory.DirBin[dirName] then
                resolve(QuickDirectory.DirBin[dirName]); 
                break;
            end
            task.wait(0.2);
        until (DateTime.now().UnixTimestamp - startTime) >= 30;
        reject(string.format(":PromiseDirectory() has timed out getting directory '%s'",dirName));
    end);
end

--[=[
    This method converts a string path into an Instance if it is valid.
    @within QuickDirectory
    @param path string -- The path that will be used to convert to an Instance; You can use '.' or '/' but not both.
    @return T? -- The Instance that is converted from the path or nil if path/Instance is invalid.
]=]
function QuickDirectory.ConvertPathToInstance<T>(path: string) : T
    local pathArray: {string} = path:split(".");
    -- Try querying for slash dir instead of dot
    if #pathArray == 1 then
        pathArray = path:split("/");
    end
    if #pathArray > 1 then
        local currentInstance: Instance = game;
        -- If game was passed remove it from the path array
        if pathArray[1] == "game" then table.remove(pathArray,1); end
        for i = 1,#pathArray do
            local queryInstance: Instance? = currentInstance:FindFirstChild(pathArray[i]);
            if queryInstance then
                currentInstance = queryInstance;
            else
                -- Failed to path to instance
                warn(QuickDirectory._ConvertOut(string.format(":ConvertPathToInstance() failed to path to instance with path: %s at '%s'",path,pathArray[i])));
                return nil;
            end
        end
        return currentInstance;
    end
    return nil;
end

--[=[
    This method is used internally for logging purposes it builds a message with the class prefix into a final message. Ex: QuickDirectory: message
    @within QuickDirectory
    @private
    @param message string -- The message to build the class prefix into.
    @return string -- The final message built with message & class prefix
]=]
function QuickDirectory._ConvertOut(message: string) : string
    return string.format("[QuickDirectory]: %s",message);
end

return QuickDirectory;