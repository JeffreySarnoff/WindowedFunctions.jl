# inandout

#=

Tables.columntable are column-oriented, each column valued as a vector a tuple
TypedTables are row-oriented, each row valued as a namedtuple
Tables.rowtable are row-oriented by e.g. `collect(columnoriented')`

=#

sourcefile = filename
targetfile = 

sourcestream = BufferedInputStream(open(filename))

targetstream = BufferedOutputStream(open(filename, "w")) # wrap an IOStream