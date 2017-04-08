function sphere_vol(r)
  return 4/3 * pi * r^3
end

quadratic(a, sqr_term, b) = (-b + sqr_term) / 2a

function quadratic2(a::Float64, b::Float64, c::Float64)
  sqr_term = sqrt(b^2 -4a * c)
  r1 = quadratic(a, sqr_term, b)
  r2 = quadratic(a, -sqr_term, b)
  r1, r2
end

vol = sphere_vol(3)

function printsum(a)
  println(summary(a), ": ", repr(a))
end

function loop1()
  for i in 1:5
    print(i, ", ")
  end
end

function loop2()
  for i = 1:5
    print(i, ", ")
  end
  println()
end

function loop3()
  a1 = [1,2,3,4]
  for i in a1
    print(i, ", ")
  end
  println()
end

function loop4()
  a2 = collect(1:20)
  for i in a2
    if i % 2 != 0
      continue
    end
    print(i, ", ")
    if i >= 8
      break
    end
  end
  println()
end

function loop5()
  a1 = [1,2,3,4]
  while !isempty(a1)
    print(pop!(a1), ", ")
  end
  println()
end

function loop6()
  d1 = Dict(1=>"one", 2=>"two", 3=>"three")
  for k in sort(collect(keys(d1)))
    print(k, ": ", d1[k], ", ")
  end
  println()
end

function loop7()
  a3 = ["one", "two", "three"]
  for (i, v) in enumerate(a3)
    print(i, ": ", v, ", ")
  end
  println()
end

function loop8()
  a4 = map((x) -> x^2, [1,2,3,7])
  print(a4)
end

function quick_sort(arr)
  if length(arr) <= 1
    return arr
  end

  pivot = arr[1]
  less = typeof(arr[])[]
  equal = typeof(arr[])[]
  greater = typeof(arr[])[]

  for x in arr
    if x < pivot
      push!(less, x)
    elseif x > pivot
      push!(greater, x)
    else
      push!(equal, x)
    end
  end

  append!(quick_sort(less), append!(equal, quick_sort(greater)))
end
