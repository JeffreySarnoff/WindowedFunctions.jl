```
    datastreams
```

```
There are four sorts of datastreams available when 
`rolling`, `tiling`, or `running` windowed functions.
```
| datastream   | window functions    | over subsequences of |
|:-------------|:--------------------|:---------------------|
| 1 vector     | max, sum, mean      | individual values    |
| 2 vectors    | cor, cov            | ordered pairs        |
| 3 vectors    | clamp, midof3       | ordered triples      |
| _each matrix column is processed as a single vector_      |
| matrix       | as with 1 vector    | column values        |


Each datastream is composed of one or more
data sequence[s].  The most fundamental
datastream is the sequence of values
that populate a vector. A function of
one argument is applied over successive
windows onto the data vector.
Where the datastream is a matrix, every
column is an independant vector.


----

##### [using `datastreams`](../use/datastreams.md)

See also: [`rolling`](rolling.md),
          [`tiling`](tiling.md),
          [`running`](running.md)
