
@generated function harmonicMean(args...)
  ex = :(0)
  for i = 1:length(args)
    ex = :($ex + 1 / args[$i])
  end
  return :(length(args) / $ex)
end



function harmonicMeanImpl(args...)
  ex = :(0)
  for i = 1:length(args)
    ex = :($ex + 1 / args[$i])
  end
  return :(length(args) / $ex)
end
