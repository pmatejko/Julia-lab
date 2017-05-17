

macro changeSymbolValue(sym, val)
  return esc(:($sym = $val))
end

macro fill_series(ex)
  indexes = Array{Int,1}()

  arr = eval(ex.args[1].args[1])
  findIndexes(ex.args, indexes)

  max, min = maxAndMin(indexes)
  diff = max - min
  fst = diff - indexes[1] + 1
  last = length(arr) - indexes[1]

  global sym = 0
  ex.args = changeSymbols(ex.args, :(sym))

  for i = fst:last
    @changeSymbolValue sym i
    eval(ex)
  end

  return arr
end




function findIndexes(ex::Array{Any,1}, ind)
  for i = 1:length(ex)
    findIndexes(ex[i], ind)
  end
end

function findIndexes(ex::Expr, ind)
  if ex.head == :call
    findIndexes(ex.args, ind)
  elseif ex.head == :ref
    findOneIndex(ex.args[2], ind)
  end
end

function findIndexes(ex::Symbol, ind)
end

function findOneIndex(ex::Symbol, ind)
  push!(ind, 0)
end

function findOneIndex(ex::Expr, ind)
  index = eval(Expr(:call, ex.args[1], ex.args[3]))
  push!(ind, index)
end

function changeSymbols(ex::Array{Any,1}, ind::Symbol)
  for i = 1:length(ex)
    ex[i] = changeSymbols(ex[i], ind)
  end
  ex
end






function changeSymbols(ex::Expr, ind::Symbol)
  if ex.head == :call
    for i = 1:length(ex.args)
      ex.args[i] = changeSymbols(ex.args[i], ind)
    end
  elseif ex.head == :ref
    ex.args[2] = changeOneSymbol(ex.args[2], ind)
  end

  ex
end

function changeSymbols(ex::Symbol, ind::Symbol)
  ex
end

function changeOneSymbol(ex::Symbol, ind::Symbol)
  ex = :($ind)
end

function changeOneSymbol(ex::Expr, ind::Symbol)
  ex.args[2] = :($ind)
  ex
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
