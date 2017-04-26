
# Proporcje czasu spędzonego w każdej z fun
# przestają odpowiadać rzeczywistości
# dla delay = 0.29 (około)
# (wcześniej zaczynają być mniej dokładne)

function fun1()
  for i in 1:100000
    string(i)
  end
end

function fun2()
  for i in 1:10000
    string(i)
  end
end

function main()
  for i in 1:500
    fun1()
    fun2()
  end
end
