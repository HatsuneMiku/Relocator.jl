# -*- coding: utf-8 -*-
# Relocator

VERSION >= v"0.4.0-dev+6521" && __precompile__()
module Relocator

export searchResDll
export _init, _close, _mf
export _rel

function searchResDll(bp::AbstractString, rp::AbstractString, fa::Bool)
  if length(bp) == 0
    if isdir("." * "/" * rp)
      bp = "./" * rp
    elseif isdir(".." * "/" * rp)
      bp = "../" * rp
    else
      bp = "."
    end
  else
    if isdir(bp * "/" * rp)
      bp *= "/" * rp
    else
      if fa; bp *= "/" * rp end
    end
  end
  return bp
end

immutable Rel
  dct::Dict{Symbol, Ptr{Void}}

  function Rel(d=Dict{Symbol, Ptr{Void}}())
    r = new(d)
    # finalizer(r, _close) # type must not be immutable / only called by gc() ?
    return r
  end
end

function _init(r::Rel, sym::Array{Symbol,1}, bp::AbstractString)
  if isempty(r.dct)
    mp = searchResDll(bp, "dll", false) * "/"
    for s in sym
      r.dct[s] = Base.Libdl.dlopen_e(symbol(mp, string(s)))
      if r.dct[s] == C_NULL
        throw(ArgumentError("not found module ':$(s)'"))
      end
    end
  end
end

function _close(r::Rel)
  for s in keys(r.dct)
    Base.Libdl.dlclose(pop!(r.dct, s))
  end
end

const _rel = Rel()

# without parameter _rel
function _mf(md::Symbol, fn::Symbol)
  c = Base.Libdl.dlsym_e(_rel.dct[md], fn)
  if c == C_NULL
    throw(ArgumentError("not found function '$(fn)' in ':$(md)'"))
  end
  return c
end

end
