local insert = table.insert
local remove = table.remove
local resume = coroutine.resume
local running = coroutine.running
local yield = coroutine.yield
local wrap = coroutine.wrap

local function Init()
	---@class mutex
	local mutex = {}
	mutex.__index = mutex

	--- wait for mutex is unlocked
	function mutex:Wait(this)
		this = this or running()
		if not this then
			error("mutex:Wait() must be runned on coroutine!")
		end
		if self.__locked then
			local wait = self.__wait
			if not wait then
				wait = {}
				self.__wait = wait
			end
			insert(wait,this)
			return yield(mutex)
		end
	end

	function mutex:Lock(this)
		this = this or running()
		if not this then
			error("mutex:Lock() must be runned on coroutine!")
		end
		self:Wait(this)
		self.__locked = true
	end

	function mutex:Unlock()
		local wait = self.__wait
		if wait and #wait ~= 0 then
			local this = remove(wait,1)
			wrap(resume)(this)
			return mutex
		end
		self.__locked = false
	end

	function mutex:IsLocked()
		return self.__locked
	end

	local mutexList = {}
	mutex.MutexList = mutexList
	function mutex:Destroy(force)
		local wait = self.__wait
		if (not force) and wait and #wait ~= 0 then
			error("mutex:Destroy() cannot be runned when lock list not empty. (give force argument to bypass lock list checking)")
		end
		local id = self.id
		if id then
			mutexList[id] = nil
		end
		setmetatable(self,nil)
	end

	function mutex.New(id)
		if id and mutexList[id] then
			return mutexList[id]
		end
		local new = {} ---@type mutex
		setmetatable(new,mutex)
		if id then
			mutexList[id] = new
		end
		return new
	end

	return mutex
end

do
	local this = Init()
	this.Init = Init

	return this
end
