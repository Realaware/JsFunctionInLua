if (not getgenv) then return end;

local Functions = {};
Functions.__index = Functions;

getgenv().this = setmetatable({}, {
   __index = function(Self, index)
      local Caller = tostring(debug.getinfo(2).func);
      if (Caller) then
         if (index == 'get_self') then
            return rawget(Self, Caller) or {};
         end
         return rawget(rawget(Self, Caller) or {}, index);
      end
   end,
   __newindex = function(Self, index, value)
      local Caller = debug.getinfo(2).func;
      if (Caller) then
         if (typeof(rawget(Self, tostring(Caller))) ~= 'table') then
            rawset(Self, tostring(Caller), {});
         end
         if (string.sub(index, 1, 1) == '@') then
            return rawset(Self, string.sub(index, 2, #index), value);
         end
         return rawset(Self[tostring(Caller)], index, value); 
      end
   end
});

function Functions.new(func)
   if (typeof(func) == 'function') then
      local Caller = tostring(func);

      return setmetatable({
         call = function(thisArg, ...)
            if (thisArg == this) then
               this['@'..Caller] = this[tostring(debug.getinfo(2).func)];
            else
               this['@'..Caller] = thisArg;
            end
         end,
         length = debug.getinfo(func).numparams or 0,
         arguments = '@Deprecated',
         prototype = {},
         caller = debug.getinfo(2).func or nil,
         name = debug.getinfo(func).name or nil,
      },{
         __call = function(Self, ...)
            func(...);
         end
      })   
   end
end

return Functions
