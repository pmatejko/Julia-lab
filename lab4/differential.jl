using DifferentialEquations
using Gadfly
using DataFrames

@ode_def LotkaVolterra begin
  dx = A * x - B * x*y
  dy = -C * y + D * x*y
end A => 1.0 B => 1.0 C => 1.0 D => 1.0


function solveLV(a::Float64, b::Float64, c::Float64, d::Float64, ux::Float64, uy::Float64, id::String, file = "results.csv")

  f = LotkaVolterra()
  f.A, f.B, f.C, f.D = a, b, c, d

  timespan = (0.0, 10.0)
  u0 = [ux, uy]

  problem = ODEProblem(f, u0, timespan)
  solution = solve(problem, RK4(), dt = 0.01)

  dataframe = DataFrame(time = solution.t, prey = map(x -> x[1], solution.u), predator = map(x -> x[2], solution.u), experiment = id)

  header = isfile(file) ? false : true

  open(file, "a") do stream
    printtable(stream, dataframe, header = header)
  end

end

function solveLV(a,b,c,d,ux,uy,id, file = "results.csv")
  f = Float64
  s = string
  solveLV(f(a),f(b),f(c),f(d),f(ux),f(uy),s(id),file)
end




function experiments(file = "results.csv", expNum = 4)
  r() = 10 * rand()

  expIDs = Vector{String}()

  for i = 1:expNum
    push!(expIDs, string("exp", i))
    solveLV(r(),r(),r(),r(),r(),r(),expIDs[i],file)
  end

  df = readtable(file)

  for i in expIDs
    expDF = df[df[:experiment] .== i, :]
    println("Experiment ", i)
    print("Min predators: ", minimum(expDF[:predator]))
    println(", Min prey: ", minimum(expDF[:prey]))
    print("Max predators: ", maximum(expDF[:predator]))
    println(", Max prey: ", maximum(expDF[:prey]))
    print("Average predators: ", mean(expDF[:predator]))
    println(", Average prey: ", mean(expDF[:prey]), "\n\n")
  end

  df[:difference] = df[:predator] - df[:prey]

  return df
end
