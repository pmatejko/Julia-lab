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
