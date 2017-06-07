#  Results for height=2000, width=2000,
#  tested on laptop with 2 cores and 4 threads:
#
#  Before:
#  1.523152 seconds (12.00 M allocations: 671.387 MB, 6.24% gc time)
#
#  Parallel for:
#  4 workers: 0.854855 seconds (2.05 k allocations: 67.685 KB)
#  3 workers: 0.941371 seconds (1.22 k allocations: 35.547 KB)
#  2 workers: 0.830656 seconds (818 allocations: 23.547 KB)
#  1 worker : 1.516910 seconds (416 allocations: 12.141 KB)
#
#  pmap:
#  4 workers: 1.206037 seconds (610.37 k allocations: 18.314 MB, 0.22% gc time)
#  3 workers: 1.222275 seconds (612.68 k allocations: 18.247 MB, 0.23% gc time)
#  2 workers: 1.373518 seconds (610.86 k allocations: 18.155 MB)
#  1 worker : 2.309346 seconds (609.41 k allocations: 18.044 MB, 0.11% gc time)
#
#  Workers with manually split jobs:
#  4 workers: 0.823434 seconds (1.05 k allocations: 64.047 KB)
#  3 workers: 0.893565 seconds (795 allocations: 48.891 KB)
#  2 workers: 0.819393 seconds (524 allocations: 31.938 KB)
#  1 worker : 1.530193 seconds (266 allocations: 15.516 KB)

@everywhere module JSet

using Plots
Plots.gr()



function generate_julia(z; c=2, maxiter=200)
    for i = 1:maxiter
        if abs(z) > 2
            return i-1
        end
        z = z^2 + c
    end
    maxiter
end

function calc_julia!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
    for y = width_start:width_end
        for x = 1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
end

function calc_julia_main(h,w)
    xmin, xmax = -2,2
    ymin, ymax = -1,1
    xrange = linspace(xmin, xmax, w)
    yrange = linspace(ymin, ymax, h)
    julia_set = Array(Int64, (w, h))
    @time calc_julia!(julia_set, xrange, yrange, height=h, width_end=w)

    Plots.heatmap(xrange, yrange, julia_set, dpi=1000, size=(w,h))
    png("julia")
end



#------------------------------------------------------



function calc_julia_parallel_for!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
    @sync @parallel for y = width_start:width_end
        for x = 1:height
            z = xrange[x] + 1im*yrange[y]
            julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
        end
    end
end

function parallel_for_main(h,w)
    xmin, xmax = -2,2
    ymin, ymax = -1,1
    xrange = linspace(xmin, xmax, w)
    yrange = linspace(ymin, ymax, h)
    julia_set = SharedArray(Int64, (w, h))

    @time calc_julia_parallel_for!(julia_set, xrange, yrange, height=h, width_end=w)

    Plots.heatmap(xrange, yrange, julia_set, dpi=1000, size=(w,h))
    png("julia")
end



#--------------------------------------



function calc_julia_pmap!(julia_set, xrange, yrange; maxiter=200, height=400, width_start=1, width_end=400)
  @sync pmap(y ->
    for x = 1:height
      z = xrange[x] + 1im*yrange[y]
      julia_set[x, y] = generate_julia(z, c=-0.70176-0.3842im, maxiter=maxiter)
    end
  , width_start:width_end)
end

function pmap_main(h,w)
    xmin, xmax = -2,2
    ymin, ymax = -1,1
    xrange = linspace(xmin, xmax, w)
    yrange = linspace(ymin, ymax, h)
    julia_set = SharedArray(Int64, (w, h))

    @time calc_julia_pmap!(julia_set, xrange, yrange, height=h, width_end=w)

    Plots.heatmap(xrange, yrange, julia_set, dpi=1000, size=(w,h))
    png("julia")
end



#-------------------------------------------



function workers_main(h,w)
   xmin, xmax = -2,2
   ymin, ymax = -1,1
   xrange = linspace(xmin, xmax, w)
   yrange = linspace(ymin, ymax, h)
   julia_set = SharedArray(Int64, (w, h))

   widths = Dict{Int64, Tuple{Int64,Int64}}()
   columnsForWorker = div(w, nworkers())

   i = 0
   for p in workers()
     if i+1 == nworkers()
       merge!(widths, Dict(p => ((columnsForWorker*i + 1), w) ))
     else
       merge!(widths, Dict(p => ((columnsForWorker*i + 1), ((i+1) * columnsForWorker)) ))
       i += 1
     end
   end


   @time @sync begin
     for p in workers()
       @async remotecall_wait(calc_julia!, p, julia_set, xrange, yrange, height=h, width_start = get(widths, p, -1)[1], width_end = get(widths, p, -1)[2])
     end
   end
   

   Plots.heatmap(xrange, yrange, julia_set, dpi=1000, size=(w,h))
   png("julia")
end

end
