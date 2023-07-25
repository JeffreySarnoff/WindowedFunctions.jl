
```
using RollingFunctions

𝐷𝑎𝑡𝑎 = [1, 2, 3, 4, 5]
𝐹𝑢𝑛𝑐 = sum
𝑆𝑝𝑎𝑛 = 3

result = running(𝐹𝑢𝑛𝑐,𝐷𝑎𝑡𝑎, 𝑆𝑝𝑎𝑛)
julia> result
3-element Vector{Int64}:
  6
  9
 12

#=
The first  windowed value is the 𝐹𝑢𝑛𝑐 (sum) of the first  𝑆𝑝𝑎𝑛 (3) values in 𝐷𝑎𝑡𝑎.
The second windowed value is the 𝐹𝑢𝑛𝑐 (sum) of the second 𝑆𝑝𝑎𝑛 (3) values in 𝐷𝑎𝑡𝑎.
The third  windowed value is the 𝐹𝑢𝑛𝑐 (sum) of the third  𝑆𝑝𝑎𝑛 (3) values in 𝐷𝑎𝑡𝑎.

There can be no fourth value as the third value used the fins entries in𝐷𝑎𝑡𝑎.
=#

julia> sum(𝐷𝑎𝑡𝑎[1:3]), sum(𝐷𝑎𝑡𝑎[2:4]), sum(𝐷𝑎𝑡𝑎[3:5])
(6, 9, 12)

If the width of each subsequence increases to 4..
𝑆𝑝𝑎𝑛 = 4
result = running(𝐹𝑢𝑛𝑐,𝐷𝑎𝑡𝑎, 𝑆𝑝𝑎𝑛);

result
2-element Vector{Int64}:
 10
 14
```

##### [approaching `running`](../approach/running.md)
