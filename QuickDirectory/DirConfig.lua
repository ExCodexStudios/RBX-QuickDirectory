-- ExponentialCodexStudios. 2022-2022. Creative Commons. CC BY-ND 4.0. https://creativecommons.org/licenses/by-nd/4.0/.
type Object = {[string]: any};

local isServer: boolean = game:GetService("RunService"):IsServer();

local function safeRequire(moduleScript: ModuleScript) : {[string]: any}?
    local success: boolean,result: {[string]: any} | string = pcall(require,moduleScript);
    if success then
        return result;
    else
        warn("[DirConfig] failed to require '"..tostring(moduleScript.Name).."' with: ",result);
    end
    return nil;
end

--- @class DirConfig
--- This is the QuickDirectory config, you can insert server and client directories that will be used by QuickDirectory.

--[=[
    @type Object {[string]: any}
    @within DirConfig
    Represents anything that is a table with strings as it's keys and any value.
]=]
local DirConfig = {};
--[=[
    @prop ServerDirs Object
    @within DirConfig
    The server directories that will be loaded into QuickDirectory for server purposes.
]=]
DirConfig.ServerDirs = {
    
};
--[=[
    @prop SharedDirs Object
    @within DirConfig
    The shared directories that will be loaded into QuickDirectory for server/client purposes.
]=]
DirConfig.SharedDirs = {

};


return DirConfig;