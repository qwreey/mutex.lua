export type id = string
export type mutex = {
	ID: id?,
	New: (id:string?)->mutex;
	Wait: (self:mutex,thisThread:thread?)->(),
	Lock: (self:mutex,thisThread:thread?)->(),
	Unlock: (self:mutex)->(),
	IsLocked: (self:mutex)->boolean,
	Destroy: (self:mutex,force:boolean?)->(),
}
export type module = {
	New: (id:string?)->mutex;
	MutexList: {[id]: mutex};
}
export type init = ()->module

return require(script.main) :: module & { Init: init }
