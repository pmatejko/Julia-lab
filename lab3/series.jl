

macro fill_series(ex)

  arr = eval(ex.args[1].args[1])

  if typeof(ex.args[1].args[2]) == Symbol
    sym = ex.args[1].args[2]
  else
    sym = ex.args[1].args[2].args[2]
  end

  indexes = Vector{Int}()
  findIndexes!(ex.args, indexes)

  max, min = maxAndMin(indexes)
  diff = max - min
  fst = diff - indexes[1] + 1
  last = length(arr) - indexes[1]
  range = fst:last

  quote
    for $sym in $range
      $ex
    end
  end

end




function findIndexes!(ex::Array{Any,1}, ind::Array{Int,1})
  for i = 1:length(ex)
    findIndexes!(ex[i], ind)
  end
end

function findIndexes!(ex::Expr, ind::Array{Int,1})
  if ex.head == :call
    findIndexes!(ex.args[2:end], ind)
  elseif ex.head == :ref
    findOneIndex!(ex.args[2], ind)
  end
end

function findIndexes!(ex::Number, ind::Array{Int,1}) end

function findIndexes!(ex::Symbol, ind::Array{Int,1}) end



function findOneIndex!(ex::Symbol, ind::Array{Int,1})
  push!(ind, 0)
end

function findOneIndex!(ex::Expr, ind::Array{Int,1})
  index = eval(Expr(:call, ex.args[1], ex.args[3]))
  push!(ind, index)
end




function maxAndMin(arr::Array{Int,1})
  max = min = arr[1]

  for i = 2:length(arr)
    if arr[i] > max
      max = arr[i]
    end
    if arr[i] < min
      min = arr[i]
    end
  end

  max, min
end
