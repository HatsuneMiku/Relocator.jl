# -*- coding: utf-8 -*-

import Relocator
import Relocator: _mf
using Base.Test

function testHere(r, p::Array{UInt8,1})
  m = sizeof(p)
  # println(m)
  ccall(_mf(r, :_dummy, :here), Ptr{Cchar}, (Ptr{Cchar}, Cint,), pointer(p), m)
end

function checkPtrCchar(r, p::Array{UInt8,1}, a::Array{ASCIIString,1})
  testHere(r, p)
  println(bytestring(p))
  for s in a
    if ccall(:strcmp, Cint, (Ptr{Cchar}, Ptr{Cchar},),
      pointer(p), pointer(s.data)) == 0
      return true
    end
  end
  return false
end

println("Testing Relocator")

println("1")
r1 = Relocator.Rel()
Relocator._init(r1, [:_dummy], "")
p1 = "_dummy_9b".data
@test checkPtrCchar(r1, p1, ["dll", "test", "prjroot"])
Relocator._close(r1)

println("2")
r2 = Relocator.Rel()
Relocator._init(r2, [:_dummy], ".")
p2 = "_dummy_9b".data
@test checkPtrCchar(r2, p2, ["dll", "test", "prjroot"])
Relocator._close(r2)

println("3")
r3 = Relocator.Rel()
try
  Relocator._init(r3, [:_dummy], "..")
  p3 = Array{UInt8,1}([49,50,51,52,53,54,55,56,57])
  @test checkPtrCchar(r3, p3, ["dll", "prjroot"]) # without "test"
catch err
  println(err) # ArgumentError("not found module ':_dummy'")
finally
  Relocator._close(r3)
end

@test false != true
println("ok")
