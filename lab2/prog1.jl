

function fun1()
  strings = String[]
  for i in 1:100000
    push!(strings, string(i))
  end
end

function fun2()
  strings = String[]
  for i in 1:10000
    push!(strings, string(i))
  end
end

function main()
  for i in 1:500
    fun1()
    fun2()
  end
end
