local ffi = require("ffi")
    function vmt_entry(instance, index, type)
		return ffi.cast(type, (ffi.cast("void***", instance)[0])[index])
	end

	function vmt_thunk(index, typestring)
		local t = ffi.typeof(typestring)
		return function(instance, ...)
			assert(instance ~= nil)
			if instance then
				return vmt_entry(instance, index, t)(instance, ...)
			end
		end
	end

	function vmt_bind(module, interface, index, typestring)
		local instance = client.create_interface(module, interface) or error("invalid interface")
		local fnptr = vmt_entry(instance, index, ffi.typeof(typestring)) or error("invalid vtable")
		return function(...)
			return fnptr(instance, ...)
		end
	end

	native_GetNetChannelInfo = vmt_bind("engine.dll", "VEngineClient014", 78, "void*(__thiscall*)(void*)")
	local native_GetName = vmt_thunk(0, "const char*(__thiscall*)(void*)")
	local native_GetAddress = vmt_thunk(1, "const char*(__thiscall*)(void*)")
	native_IsLoopback = vmt_thunk(6, "bool(__thiscall*)(void*)")
	local native_IsTimingOut = vmt_thunk(7, "bool(__thiscall*)(void*)")
	native_GetAvgLoss = vmt_thunk(11, "float(__thiscall*)(void*, int)")
	native_GetAvgChoke = vmt_thunk(12, "float(__thiscall*)(void*, int)")
	native_GetTimeSinceLastReceived = vmt_thunk(22, "float(__thiscall*)(void*)")
	local native_GetRemoteFramerate = vmt_thunk(25, "void(__thiscall*)(void*, float*, float*, float*)")
	local native_GetTimeoutSeconds = vmt_thunk(26, "float(__thiscall*)(void*)")

	local pflFrameTime = ffi.new("float[1]")
	local pflFrameTimeStdDeviation = ffi.new("float[1]")
	local pflFrameStartTimeStdDeviation = ffi.new("float[1]")

	function GetRemoteFramerate(netchannelinfo)
		native_GetRemoteFramerate(netchannelinfo, pflFrameTime, pflFrameTimeStdDeviation, pflFrameStartTimeStdDeviation)
		if pflFrameTime ~= nil and pflFrameTimeStdDeviation ~= nil and pflFrameStartTimeStdDeviation ~= nil then
			return pflFrameTime[0], pflFrameTimeStdDeviation[0], pflFrameStartTimeStdDeviation[0]
		end
	end

	function GetAddress(netchannelinfo)
		local addr = native_GetAddress(netchannelinfo)
		if addr ~= nil then
			return ffi.string(addr)
		end
	end

	function GetName(netchannelinfo)
		local name = native_GetName(netchannelinfo)
		if name ~= nil then
			return ffi.string(name)
		end
	end