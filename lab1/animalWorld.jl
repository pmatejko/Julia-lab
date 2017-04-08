abstract Zwierzę
type MartweZwierzę <: Zwierzę end

type Drapieżnik <: Zwierzę
  nazwa::String
end
type Ofiara <: Zwierzę
  nazwa::String
end

type MiejsceJestJużZajęte <: Exception end
type NieZnalezionoZwierzęcia <: Exception end

#----------------------------------------------------

function wyświetl()
  for i in 1:N
    for j in 1:N
      if isdefined(świat, (j-1)*N + i) && !(typeof(świat[i,j]) <: MartweZwierzę)
        print(string(świat[i,j].nazwa, " "))
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
      if isdefined(świat, (j-1)*N + i) && świat[i,j] == zwierzę
        return i,j
      end
    end
  end
  throw(NieZnalezionoZwierzęcia())
end





function dodajZwierzę(zwierzę::Zwierzę, x::Int, y::Int)
  if !isdefined(świat, (y-1)*N + x) || typeof(świat[x,y]) <: MartweZwierzę
    świat[x,y] = zwierzę
    wyświetl()
  else
    throw(MiejsceJetJużZajęte())
  end
end

function odległość(zw1::Zwierzę, zw2::Zwierzę)
  (x1, y1) = znajdźZwierzę(zw1)
  (x2, y2) = znajdźZwierzę(zw2)
  abs(x1 - x2) + abs(y1 - y2)
end

function interakcja(zw1::Drapieżnik, zw2::Ofiara)
  (x, y) = znajdźZwierzę(zw2)
  świat[x,y] = MartweZwierzę()
  wyświetl()
end

function interakcja(zw1::Ofiara, zw2::Drapieżnik)
  for i in 1:N
    for j in 1:N
      if !isdefined(świat, (j-1)*N + i) || typeof(świat[i,j]) <: MartweZwierzę
        (x, y) = znajdźZwierzę(zw1)
        świat[i,j] = zw1
        świat[x,y] = MartweZwierzę()
        wyświetl()
        return
      end
    end
  end
end

function interakcja(zw1::Drapieżnik, zw2::Drapieżnik)
  "Wrrrr"
end

function interakcja(zw1::Ofiara, zw2::Ofiara)
  "Beeee"
end



#--------------------------------------------------

println("Podaj długość boku planszy: ")
N = parse(Int, input())

świat = Array{Zwierzę, 2}(N,N)

małpa = Ofiara("małpa")
okoń = Ofiara("okoń")
tygrys = Drapieżnik("tygrys")
dodajZwierzę(małpa,1,1)
dodajZwierzę(okoń,3,4)
dodajZwierzę(tygrys,5,5)

odległość(okoń, tygrys)

#--------------------------------------------------
