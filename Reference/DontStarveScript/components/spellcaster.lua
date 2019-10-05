local SpellCaster = Class(function(self, inst)
	self.inst = inst
	self.spell = nil
	self.spelltest = nil
	self.onspellcast = nil
	self.canusefrominventory = true
	self.canuseontargets = false
	self.canuseonpoint = false
end)

function SpellCaster:SetSpellFn(fn)
	self.spell = fn
end

function SpellCaster:SetSpellTestFn(fn)
	self.spelltest = fn
end

function SpellCaster:SetOnSpellCastFn(fn)
	self.onspellcast = fn
end

function SpellCaster:CastSpell(target, pos)
	if self.spell then
		self.spell(self.inst, target, pos)

		if self.onspellcast then
			self.onspellcast(self.inst, target, pos)
		end
	end
end

function SpellCaster:CanCast(doer, target, pos)
	if self.spelltest then
		return self.spelltest(self.inst, doer, target, pos) and self.spell ~= nil
	end

	return self.spell ~= nil

end

function SpellCaster:CollectInventoryActions(doer, actions)
	if self:CanCast(doer) and self.canusefrominventory then
		table.insert(actions, ACTIONS.CASTSPELL)
	end
end

function SpellCaster:CollectEquippedActions(doer, target, actions, right)
	if right and self:CanCast(doer, target) and self.canuseontargets then
		table.insert(actions, ACTIONS.CASTSPELL)
	end
end

function SpellCaster:CollectPointActions(doer, pos, actions, right)
    if right and self:CanCast(doer, nil, pos) and self.canuseonpoint then
		table.insert(actions, ACTIONS.CASTSPELL)
	end
end

return SpellCaster