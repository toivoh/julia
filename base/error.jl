## native julia error handling ##

error(e::Exception) = throw(e)
error{E<:Exception}(::Type{E}) = throw(E())
error(s::String) = throw(ErrorException(s))
error(s...)      = throw(ErrorException(string(s...)))

macro unexpected()
    :(error("unexpected branch reached"))
end

## system error handling ##

errno() = ccall(:jl_errno, Int32, ())
strerror(e::Integer) = bytestring(ccall(:strerror, Ptr{Uint8}, (Int32,), e))
strerror() = strerror(errno())
system_error(p, b::Bool) = b ? throw(SystemError(string(p))) : nothing

## assertion functions and macros ##

assert(x) = assert(x,'?')
assert(x,labl) = x ? nothing : throw(AssertionError(string(labl)))

# @assert is for things that should never happen
macro assert(ex)
    :($(esc(ex)) ? nothing : throw(AssertionError($(string(ex)))))
end
# @expect is for things that might happen
# if e.g. a function is called with the wrong arguments
macro expect(args...)
    if !(1 <= length(args) <= 2)
        error("@expect: expected one or two arguments")
    end
    pred = args[1]
    err = (length(args) == 2) ? args[2] : :_msg
    esc(:( if !($pred)
        let _msg = $(string("expected ",sprint(show_unquoted,pred)," == true"))
            error($err)
        end
    end))
end
