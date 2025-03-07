function walkmodules(f, x::Module)
    f(x)
    for n in names(x; all = true)
        # `isdefined` and `getproperty` can trigger deprecation warnings
        if Base.isbindingresolved(x, n) && !Base.isdeprecated(x, n)
            isdefined(x, n) || continue
            y = getproperty(x, n)
            if y isa Module && y !== x && parentmodule(y) === x
                walkmodules(f, y)
            end
        end
    end
end

"""
    undefined_exports(m::Module) :: Vector{Symbol}
"""
function undefined_exports(m::Module)
    undefined = Symbol[]
    walkmodules(m) do x
        for n in names(x)
            isdefined(x, n) || push!(undefined, Symbol(join([fullname(x)...; n], '.')))
        end
    end
    return undefined
end

"""
    test_undefined_exports(module::Module)

Test that all `export`ed names in `module` actually exist.

# Keyword Arguments
- `broken::Bool = false`: If true, it uses `@test_broken` instead of
  `@test`.
"""
function test_undefined_exports(m::Module; broken::Bool = false)
    if broken
        @test_broken undefined_exports(m) == []
    else
        @test undefined_exports(m) == []
    end
end
