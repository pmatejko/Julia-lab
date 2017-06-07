

function go()
  @sync begin
    current = 1

    for i in [2,3,1]
      @async begin

        while true
          if i == current
            println(i)
            if current == 3
              println()
              sleep(1)
            end
            current = (current % 3) + 1
            yield()
          else
            yield()
          end
        end

      end
    end

  end
end
