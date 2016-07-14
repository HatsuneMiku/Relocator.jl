# -*- coding: utf-8 -*-

import Relocator
import Relocator: _mf
using Base.Test

println("Testing Relocator")

println("1")
r1 = Relocator.Rel()
Relocator._init(r1, [:_dummy], "")
p1 = "_dummy_9b".data
ccall(_mf(r1, :_dummy, :here), Ptr{Cchar}, (Ptr{Cchar}, Cint,), pointer(p1), 9)
println(bytestring(p1))
@test bytestring(p1[1:4]) == "dll\0"
Relocator._close(r1)

println("2")
r2 = Relocator.Rel()
Relocator._init(r2, [:_dummy], ".")
p2 = "_dummy_9b".data
ccall(_mf(r2, :_dummy, :here), Ptr{Cchar}, (Ptr{Cchar}, Cint,), pointer(p2), 9)
println(bytestring(p2))
@test bytestring(p2[1:5]) == "test\0" || bytestring(p1[1:4]) == "dll\0"
Relocator._close(r2)

println("3")
r3 = Relocator.Rel()
try
  Relocator._init(r3, [:_dummy], "..")
  p3 = Array{UInt8,1}([49,50,51,52,53,54,55,56,57])
  ccall(_mf(r3, :_dummy, :here), Ptr{Cchar}, (Ptr{Cchar}, Cint,), pointer(p3), 9)
  println(bytestring(p3))
  @test bytestring(p3[1:4]) == "dll\0"
catch err
  println(err) # ArgumentError("not found module ':_dummy'")
finally
  Relocator._close(r3)
end

@test false != true
println("ok")
