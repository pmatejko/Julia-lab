abstract Zwierzę

type BrakZwierzęcia <: Zwierzę end

type Drapieżnik <: Zwierzę
  nazwa::String
end

type Ofiara <: Zwierzę
  nazwa::String
end

type MiejsceJestJużZajęte <: Exception end
type NieZnalezionoZwierzęcia <: Exception end
type BrakMiejscDoUcieczki <: Exception end

#----------------------------------------------------

function wyświetl()
  for i = 1:N
    for j = 1:N
      if !(typeof(świat[j,i]) <: BrakZwierzęcia)
        print(string(świat[j,i].nazwa, " "))
      else
        print("----- ")
      end
    end
    println()
  end
  println()
end

function znajdźZwierzę(zwierzę::Zwierzę)
  for i in 1:N
    for j in 1:N
      if świat[j,i] == zwierzę
        return j,i
      end
    end
  end
  throw(NieZnalezionoZwierzęcia())
end





function dodajZwierzę(zwierzę::Zwierzę, x::Int64, y::Int64)
  if typeof(świat[x,y]) <: BrakZwierzęcia
    świat[x,y] = zwierzę
    wyświetl()
  else
    throw(MiejsceJestJużZajęte())
  end
end

function odległość(zw1::Zwierzę, zw2::Zwierzę)
  (x1, y1) = znajdźZwierzę(zw1)
  (x2, y2) = znajdźZwierzę(zw2)
  abs(x1 - x2) + abs(y1 - y2)
end

function interakcja(zw1::Drapieżnik, zw2::Ofiara)
  (x, y) = znajdźZwierzę(zw2)
  świat[x,y] = BrakZwierzęcia()
  wyświetl()
end

function interakcja(zw1::Ofiara, zw2::Drapieżnik)
  for i = 1:N, j = 1:N
    if typeof(świat[j,i]) <: BrakZwierzęcia
      (x, y) = znajdźZwierzę(zw1)
      świat[j,i] = zw1
      świat[x,y] = BrakZwierzęcia()
      wyświetl()
      return
    end
  end
  throw(BrakMiejscDoUcieczki())
end

function interakcja(zw1::Drapieżnik, zw2::Drapieżnik)
  "Wrrrr"
end

function interakcja(zw1::Ofiara, zw2::Ofiara)
  "Beeee"
end



#--------------------------------------------------

println("Podaj długość boku planszy: ")
const N = parse(Int64, readline())

global świat = Array{Zwierzę, 2}(N,N)
fill!(świat, BrakZwierzęcia())

małpa = Ofiara("małpa")
okoń = Ofiara("okoń")
tygrys = Drapieżnik("tygrys")
dodajZwierzę(małpa,1,1)
dodajZwierzę(okoń,3,4)
dodajZwierzę(tygrys,5,5)

odległość(okoń, tygrys)

#--------------------------------------------------
