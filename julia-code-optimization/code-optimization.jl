using BenchmarkTools

#%%

function test1(x::Int)
    println("$x is an Int")
end

function test1(x::Float64)
    println("$x is a Float64")
end

function test1(x)
    println("$x is neither an Int nor a Float64")
end
#%%
test1(1)

test1(1.0)

test1("techytok")

#%%
"""
Returns x if x>0 else returns 0
"""
function test3(x)
    if x>0
        return x
    else
        return 0
    end
end
#%%
test3(2)
test3(-1)

test3(2.0)
test3(-1.0)
#%%
"""
Returns x if x>0 else returns 0
"""
function test4(x)
    if x>0
        return x
    else
        return zero(x)
    end
end
#%%
test4(-1.0)

#%%
@code_warntype test4(1.0)

#%%
function test5()
    r=0
    for i in 1:10
        r+=sin(i)
    end
    return r
end

function test6()
    r=0.0
    for i in 1:10
        r+=sin(i)
    end
    return r
end
#%%
@code_warntype test5()
@code_warntype test6()

@btime test5()
@btime test6()

#%%
function test7(x)
    result = 0
    if x>0
        result = x
    else
        result = 0
    end
    return result::typeof(x)
end
#%%
test7(-2.0)

#%%
function take_a_breath()
    sleep(22*1e-3)
    return
end

function test8()
    r=zeros(100,100)
    take_a_breath()
    for i in 1:100
        A=rand(100,100)
        r+=A
    end
    return r
end

#%%
test8()
@profiler test8()
Juno.Profile.print()

#%%
using BenchmarkTools
arr1=zeros(10000)

@btime for i in 1:10000
    arr1[i] = 1
end

@btime @inbounds for i in 1:10000
    arr1[i] = 1
end

#%%
using StaticArrays

arr1 = [i for i in 1:1000]
arr2 = @SVector [i for i in 1:1000]

@btime sum($arr1)

@btime sum($arr2)

#%%
arr1 = zeros(100, 200)

@btime for i in 1:100
    for j in 1:200
        arr1[i,j] = 1
    end
end


@btime for j in 1:200
    for i in 1:100
        arr1[i,j] = 1
    end
end