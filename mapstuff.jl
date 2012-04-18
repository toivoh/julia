# return common value of f(x) for x in itr, if it exists; error otherwise
function same(f::Function, itr)
    s = start(itr)
    if done(itr, s)
        error("same: need at least one element!")
    end
    (x, s) = next(itr, s)
    y = f(x) 
    while !done(itr, s)
        (x, s) = next(itr, s)
	if (yk = f(x)) != y
	    error("same: $f(x) not same for all elements: $y != $yk")
	end        
    end
    return y
end
same(c) = same(identity, c)

# tuple.jl:
# n argument function
map(f, ts::Tuple...) = ntuple(same(length, ts), n->f(map(t->t[n],ts)...))


# cell.jl:
map(f, a::Array{Any,1}, b::Array{Any,1}) =
    { f(a[i],b[i]) | i=1:same(length, (a, b)) }
function map(f, as::Array{Any,1}...)
    n = same(length, as)
    { f(map(a->a[i],as)...) | i=1:n }
end


# array.jl:
## N argument
function map_to(dest::StridedArray, f, As::StridedArray...)
    n = same(numel, As)
    i = 1
    ith = a->a[i]
    for i=1:n
        dest[i] = f(map(ith, As)...)
    end
    return dest
end
function map_to2(first, dest::StridedArray, f, As::StridedArray...)
    n = same(numel, As)
    i = 1
    ith = a->a[i]
    dest[1] = first
    for i=2:n
        dest[i] = f(map(ith, As)...)
    end
    return dest
end

function map(f, As::StridedArray...)
    if same(isempty, As); return As[1]; end
    first = f(map(a->a[1], As)...)
    dest = similar(As[1], typeof(first))
    return map_to2(first, dest, f, As...)
end


function assert_fail(ex)
    failed = true
    try
	eval(ex)
        failed = false
    catch err
        println(ex)
        println("threw \"$err\"\n")        
    end
    if !failed
        error("didn't fail: $ex")
    end
end

println("tuple.jl:")
map((x,y)->x*y, (1,),(2,))
assert_fail( :(map((x,y)->x*y, (1,),())) )
assert_fail( :(map((x,y)->x*y, (),(1,))) )

