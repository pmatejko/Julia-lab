# Zmiany:
#
# N i K - const
# zmienna globalna graph -> jako argument funkcji (ze zdef. typem)
# Do typów zdefiniowane typy ich pól
# Zparametryzowanie "nodes" - z Vector -> Vector{NodeType}
# Zmiana typu tablicy A z Int64 na BitArray (wypełnienie falses(N,N))
# W partition przypisanie "parts" typu
# W graph_to_str zamiana ifów na funkcje przyjmujące różne typy
# Najpierw tworzenie IOBuffer, a dopiero potem zamiana na stringa (bo string jest niemutowalny)
# W generate_random_graph dodanie funkcji ktora uzywa length(A) zamiast N*N
# Zmiana adresu na Int8, jako że korzystał jedynie z wartości 1-100
# Dodanie @simd przy większoćci forów oraz @inbounds przy odwoływaniu się do elementów tablicy
# W convert_to_graph uzycie list comprehension do stworzenia pierwszej tablicy (zamiast stworzenia pustej i pushowania)
# W petli for przegladanie najpierw wg kolumn a potem wierszy
#
#
# Before - @time Graphs.test_graph()
# 16.146923 seconds (118.46 M allocations: 12.826 GB, 14.28% gc time)
#
#
# After - @time Graphs.test_graph()
# 0.475838 seconds (1.71 M allocations: 129.165 MB, 2.89% gc time)
#
# @benchmark Graphs.test_graph()
# BenchmarkTools.Trial:
#  memory estimate:  128.95 MiB
#  allocs estimate:  1702797
#  --------------
#  minimum time:     480.882 ms (2.75% GC)
#  median time:      485.481 ms (2.72% GC)
#  mean time:        485.665 ms (2.62% GC)
#  maximum time:     493.162 ms (2.09% GC)
#  --------------
#  samples:          11
#  evals/sample:     1
#  time tolerance:   5.00%
#  memory tolerance: 1.00%

#


module Graphs

using StatsBase

export GraphVertex, NodeType, Person, Address,
       sampleTrue, generate_random_graph, get_random_person, get_random_address, generate_random_nodes,
       convert_to_graph, create_vertex,
       bfs, check_euler, partition,
       value_to_buf, graph_to_str,
       test_graph


# Types of valid graph node's values.
abstract NodeType

type Person <: NodeType
  name ::String
end

type Address <: NodeType
  streetNumber ::Int8
end

#= Single graph vertex type.
Holds node value and information about adjacent vertices =#
type GraphVertex{T<:NodeType}
  value ::T
  neighbors ::Vector{GraphVertex}
end




# Number of graph nodes.
const N = Int64(800)

# Number of graph edges.
const K = Int64(10000)


#= Generates random directed graph of size N with K edges
and returns its adjacency matrix.=#

function sampleTrue(A::BitArray{2})
  @simd for i in sample(1:length(A), K, replace=false)
    @inbounds A[i] = true
  end
end

function generate_random_graph()
    A::BitArray{2} = falses(N, N)
    sampleTrue(A)

    A
end

# Generates random person object (with random name).
function get_random_person()
  Person(randstring())
end

# Generates random person object (with random name).
function get_random_address()
  Address(rand(Int8(1):Int8(100)))
end

# Generates N random nodes (of random NodeType).
function generate_random_nodes()
  nodes = Vector{NodeType}()

  @simd for i = 1:N
    push!(nodes, rand() > 0.5 ? get_random_person()::NodeType : get_random_address()::NodeType)
  end

  nodes
end

function create_vertex(person::Person)
  GraphVertex{Person}(person, Vector{GraphVertex}())
end

function create_vertex(address::Address)
  GraphVertex{Address}(address, Vector{GraphVertex}())
end

#= Converts given adjacency matrix (NxN)
  into list of graph vertices (of type GraphVertex and length N). =#
function convert_to_graph(A::BitArray{2}, nodes::Vector{NodeType})
  graph::Array{GraphVertex,1} = [create_vertex(n) for n = nodes]

  @simd for i = 1:N
    @simd for j = 1:N
      @inbounds if A[j,i]
        @inbounds push!(graph[i].neighbors, graph[j])
      end
    end
  end

  graph
end

#= Groups graph nodes into connected parts. E.g. if entire graph is connected,
  result list will contain only one part with all nodes. =#
function partition(graph::Array{GraphVertex,1})
  parts = Set{GraphVertex}[]
  remaining = Set(graph)
  visited = bfs(graph, remaining=remaining)
  push!(parts, Set(visited))

  while !isempty(remaining)
    new_visited = bfs(graph, visited=visited, remaining=remaining)
    push!(parts, new_visited)
  end

  parts
end

#= Performs BFS traversal on the graph and returns list of visited nodes.
  Optionally, BFS can initialized with set of skipped and remaining nodes.
  Start nodes is taken from the set of remaining elements. =#
function bfs(graph::Array{GraphVertex,1}; visited::Set{GraphVertex}=Set{GraphVertex}(), remaining::Set{GraphVertex}=Set(graph))
  first = next(remaining, start(remaining))[1]
  q::Array{GraphVertex,1} = [first]
  push!(visited, first)
  delete!(remaining, first)
  local_visited::Set{GraphVertex} = Set([first])

  while !isempty(q)
    v = pop!(q)

    @simd for n in v.neighbors
      if !(n in visited)
        push!(q, n)
        push!(visited, n)
        push!(local_visited, n)
        delete!(remaining, n)
      end
    end
  end
  local_visited
end

#= Checks if there's Euler cycle in the graph by investigating
   connectivity condition and evaluating if every vertex has even degree =#
function check_euler(graph::Array{GraphVertex,1})
  if length(partition(graph)) == 1
    return all(map(v -> iseven(length(v.neighbors)), graph))
  end
  "Graph is not connected"
end

#= Returns text representation of the graph consisiting of each node's value
   text and number of its neighbors. =#

function value_to_buf(graph_buf::IOBuffer, n::Person)
  print(graph_buf, "Person: ")
  print(graph_buf, n.name)
end

function value_to_buf(graph_buf::IOBuffer, n::Address)
  print(graph_buf, "Street nr: ")
  print(graph_buf, n.streetNumber)
end

function graph_to_str(graph::Array{GraphVertex,1})
  graph_buf = IOBuffer()
  for v in graph
    print(graph_buf, "****\n")
    value_to_buf(graph_buf, v.value)
    print(graph_buf, "\nNeighbors: ")
    print(graph_buf, length(v.neighbors))
    print(graph_buf, "\n")
  end
  takebuf_string(graph_buf)
end

#= Tests graph functions by creating 100 graphs, checking Euler cycle
  and creating text representation. =#
function test_graph()
  @simd for i=1:100
    A = generate_random_graph()
    nodes = generate_random_nodes()
    graph = convert_to_graph(A, nodes)

    str = graph_to_str(graph)
    #println(str)
    println(check_euler(graph))
  end
end

end
