using DifferentialEquations
using Gadfly
using DataFrames


@ode_def LotkaVolterra begin
  dx = A * x - B * x*y
  dy = -C * y + D * x*y
end A => 1.0 B => 1.0 C => 1.0 D => 1.0


function solveLV(a::Float64, b::Float64, c::Float64, d::Float64, ux::Float64, uy::Float64, id::Symbol, file = "results.csv")
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
  s = Symbol
  solveLV(f(a),f(b),f(c),f(d),f(ux),f(uy),s(id),file)
end




function experiments(file = "results.csv", expNum = 4)
  r() = 10 * rand()

  expIDs = Vector{Symbol}()

  for i = 1:expNum
    push!(expIDs, Symbol("exp", i))
    solveLV(r(),r(),r(),r(),r(),r(),expIDs[i],file)
  end

  df = readtable(file)

  for i in expIDs
    expDF = df[df[:experiment] .== string(i), :]
    pred = expDF[:predator]
    prey = expDF[:prey]

    toPrint = DataFrame()
    toPrint[i] = [:Minimum, :Maximum, :Average]
    toPrint[:predator] = [minimum(pred), maximum(pred), mean(pred)]
    toPrint[:prey] = [minimum(prey), maximum(prey), mean(prey)]

    show(toPrint)
    println("\n\n")
  end

  df[:difference] = df[:predator] - df[:prey]

  return df
end




function drawTimeGraph(file)
  df = readtable(file)
  experiments = unique(df[:experiment])
  withDifference = :difference in names(df)
  plots = Vector{Gadfly.Plot}()

  for i in experiments
    expDF = df[df[:experiment] .== i, :]

    if(withDifference)
      push!(plots, plot(expDF, layer(y = "predator", x = "time", Geom.line),
                               layer(y = "prey", x = "time", Geom.line),
                               layer(y = "difference", x = "time", Geom.line),
                               Guide.YLabel("population"),
                               Guide.Title(i)))
    else
      push!(plots, plot(expDF, layer(y = "predator", x = "time", Geom.line),
                               layer(y = "prey", x = "time", Geom.line),
                               Guide.YLabel("population"),
                               Guide.Title(i)))
    end
  end

  set_default_plot_size(30cm, 50cm)
  vstack(plots)
end



function drawPhaseGraph(file)
  df = readtable(file)
  experiments = unique(df[:experiment])
  layers = Vector{Gadfly.Layer}()
  colors = [colorant"red", colorant"blue", colorant"green", colorant"magenta", colorant"cyan", colorant"yellow", colorant"orange", colorant"black"]

  for i in 1:length(experiments)
    expDF = df[df[:experiment] .== experiments[i], :]
    usedColor = color(colors[i % length(colors) + 1])
    push!(layers, layer(expDF, x = "prey", y = "predator", Geom.line(preserve_order = true), Theme(default_color = usedColor))...)
  end

  set_default_plot_size(15cm, 15cm)
  plot(layers, Guide.YLabel("predators"), Guide.XLabel("prey"), Guide.Title("Population"))
end
