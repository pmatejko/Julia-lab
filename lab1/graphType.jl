function graphInheritance(x)
    if x != Any
        graphInheritance(supertype(x))
        print("-->")
    end
    print(x)
end
