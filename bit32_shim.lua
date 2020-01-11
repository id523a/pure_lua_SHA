-- bit32_shim - fixed the bit32 library in ComputerCraft

local function conv(x)
  if (x >= 2147483648) then
    return x - 2147483648
  else
    return x
  end
end

local function shim_shift(func)
  return function(x,d)
    return func(conv(x),d)
  end
end

local function shim_accumulate(func,identity)
  return function(...)
    local x = conv(identity)
    for idx,val in ipairs({...}) do
      x = func(conv(x), conv(val))
    end
    return x
  end
end

bit32_old = bit32
bit32 = {
  arshift = shim_shift(bit32_old.arshift),
  band = shim_accumulate(bit32_old.band,-1),
  bnot = function(x) return bit32_old.bnot(conv(x)) end,
  bor = shim_accumulate(bit32_old.bor,0),
  btest = shim_shift(bit32_old.btest),
  bxor = shim_accumulate(bit32_old.bxor,0),
  lshift = shim_shift(bit32_old.lshift),
  rshift = shim_shift(bit32_old.rshift)
}

bit32.lrotate = function(x,d)
  return bit32.bor(bit32.lshift(x,d),bit32.rshift(x,bit32.band(32-d,31)))
end
bit32.rrotate = function(x,d)
  return bit32.bor(bit32.rshift(x,d),bit32.lshift(x,bit32.band(32-d,31)))
end

_G["bit32"] = bit32
