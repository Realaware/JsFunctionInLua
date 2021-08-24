local Function = {};

if (getgenv().tableStorage) then
    getgenv().tableStorage = getgenv().tableStorage;
else
    getgenv().tableStorage = {};
end
function Function.new(args, chunk, thisArg)
    -- basic state to make function do well.
    local maxChunkLine = 10000;

    local function typeChecker(data)
        if (typeof(data) == 'table') then
            for i,v in pairs (data)  do
                if (typeof(v) == 'table') then
                    if (typeof(v.value) ~= v.type) then
                        return false;
                    end
                end
            end
        end
        return true;
    end

    if (not typeChecker({value = chunk, type = 'string'})) then
        return error('')
    end

    if (#chunk > maxChunkLine) then
        return error('Chunk is too large.');
    end

    local function isNan(value)
        return tonumber(value) == nil;
    end

    local function replaceLine(s1, line, s2)
        local Split = string.split(s1, '\n');
        Split[line] = s2;
        
        return table.concat(Split, '\n');
    end

    local function getLineContent(s1, line)        
        return string.split(s1, '\n')[line];
    end
        
    local function RemoveRemark(String)
        local r = string.gsub(String, "--(-.-)\n","\n");

        return r;
    end

    if (thisArg) then
        -- to reset old this.
        if (string.find(chunk, 'local this = {};')) then
            chunk = chunk:gsub('local this = {};', '');
        end
        local key = tostring(math.random(1, 10000000));
        getgenv().tableStorage[key] = thisArg;
        chunk = replaceLine(chunk, 1, string.format('local this = getgenv().tableStorage[\'%s\'];\n%s', key, getLineContent(chunk, 1)));
    else
        chunk = replaceLine(chunk, 1, string.format('local this = {};\n%s', getLineContent(chunk, 1)));
    end

    local PerformCall = function(chunk)
        loadstring(chunk)();
    end
    
    return setmetatable({
        length = (function()
            local length = 0;
            if (not args) then
                return 0
            end
            for i,v in pairs (args) do
                length = length + 1
            end
            return length
        end)();
        toString = chunk;
        caller = debug.getinfo(2).func;
        bind = function(_thisArg: table)
            if (typeof(_thisArg) ~= 'table') then return end;
            return Function.new(nil , chunk, _thisArg);
        end;
        prototype = {};
        name = 'PerformCall',
    }, {
        __call = function(self, ...)
            local arg = {...};
            local suc, res = pcall(function()
                for i,v in pairs (arg) do
                    if (i > #args) then break end;
                    chunk = replaceLine(chunk, 1, string.format('local %s = \'%s\';\n%s', args[i], v, getLineContent(chunk, 1)));
                end 
                PerformCall(chunk);
            end);
            if (not suc) then
                error(res);
            end
        end
    })
end

return Function;
