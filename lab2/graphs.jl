# Zmiany:
# N i K - const
# zmienna globalna graph -> jako argument funkcji (ze zdef. typem)
# Do typów zdefiniowane typy ich pól
# Zparametryzowanie "nodes" - z Vector -> Vector{NodeType}
# Zmiana typu tablicy A z Int64 na BitArray (wypełnienie falses(N,N))
# W partition przypisanie "parts" typu
# W graph_to_str zamiana ifów na funkcje przyjmujące różne typy
# Zamiana interpolacji stringa na tworzenie z kilku stringów i zmiennych
# W generate_random_graph dodanie funkcji ktora uzywa length(A) zamiast N*N
# Zmiana adresu na Int8, jako że korzystał jedynie z wartości 1-100
# Dodanie @simd przy większoćci forów oraz @inbounds przy odwoływaniu się do elementów tablicy
#
#
# Po zmianach - @time test_graph()
# 7,369604 s  (3.59 M allocations: 9,727 GB, 29,94% gc time)
# @allocated - 10 441 325 120
#
# Przed zmianami - @time test_graph()
# 16.146923 seconds (118.46 M allocations: 12.826 GB, 14.28% gc time)
# @allocated - 13 774 531 584


module Graphs

using StatsBase

export GraphVertex, NodeType, Person, Address,
       sampleTrue, generate_random_graph, get_random_person, get_random_address, generate_random_nodes,
       convert_to_graph,
       bfs, check_euler, partition,
       value_to_str, graph_to_str, node_to_str,
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
const N = 800

# Number of graph edges.
const K = 10000


#= Generates random directed graph of size N with K edges
and returns its adjacency matrix.=#

function sampleTrue(A::BitArray{2})
  @simd for i in sample(1:length(A), K, replace=false)
    @inbounds A[i] = true
  end
end

function generate_random_graph()
    A = falses(N, N)
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
    push!(nodes, rand() > 0.5 ? get_random_person() : get_random_address())
  end
  nodes
end

#= Converts given adjacency matrix (NxN)
  into list of graph vertices (of type GraphVertex and length N). =#
function convert_to_graph(A::BitArray{2}, nodes::Vector{NodeType}, graph::Array{GraphVertex,1})
  N = length(nodes)
  push!(graph, map(n -> GraphVertex(n, GraphVertex[]), nodes)...)

  for i = 1:N, j = 1:N
      @inbounds if A[i,j]
        @inbounds push!(graph[i].neighbors, graph[j])
      end
  end
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

function value_to_str(n::Person)
  string("Person: ", n.name, "\n")
end

function value_to_str(n::Address)
  string("Street nr: ", n.streetNumber, "\n")
end

function graph_to_str(graph::Array{GraphVertex,1})
  graph_str = ""
  for v in graph
    graph_str *= "****\n"
    graph_str *= value_to_str(v.value)
    graph_str *= string("Neighbors: ", length(v.neighbors), "\n")
  end
  graph_str
end

#= Tests graph functions by creating 100 graphs, checking Euler cycle
  and creating text representation. =#
function test_graph()
  @simd for i=1:100
    graph = GraphVertex[]

    A = generate_random_graph()
    nodes = generate_random_nodes()
    convert_to_graph(A, nodes, graph)

    str = graph_to_str(graph)
    #println(str)
    println(check_euler(graph))
  end
end

end
