using Documenter

pushfirst!(LOAD_PATH, joinpath(@__DIR__, "..")) # add to environment stack

makedocs(
    # modules = [WindowedFunctions],
    sitename = "WindowedFunctions.jl",
    authors = "Jeffrey Sarnoff <jeffrey.sarnoff@gmail.com>",
    format=Documenter.HTML(
        canonical = "https://jeffreysarnoff.github.io/WindowedFunctions.jl/stable/",
        prettyurls=!("local" in ARGS),
        highlights=["yaml"],
        ansicolor=true,
    ),
    pages = Any[
        "Home" => "index.md",
        "Diagrams" => Any[
            "sequential data" => "diagrams/sequentialdata.md",
            "tiling"=>"diagrams/tiling.md"
        ],
        "Capabilites" => Any[
           "Shared Example" => "approach/sharedexample.md",
           "padding" => "approach/padding.md",
           "weights" => "approach/weights.md"
        ],
        "Approaches" => Any[
            "Designs" => Any[
                "rolling" => "approach/rolling.md",
                "tiling"  => "approach/tiling.md",
                "running" => "approach/running.md",
                "datastreams" => "approach/datastreams.md"
            ],
            "Uses" => Any[
                "rolling" => "use/rolling.md",
                "tiling"=>"use/tiling.md",
                "running"=>"use/running.md",
                "datastreams" => "use/datastreams.md",
            ],
        ],
        "Options" => Any[
            "Designs" => Any[
                "padding"=>"approach/padding.md",
                "atend"=>"approach/atend.md",
                "weights" => "approach/weights.md"
            ],
            "Uses"=>Any[
                "padding"=>"use/padding.md",
                "atend"=>"use/atend.md",
                "weights"=>"use/weights.md",
            ],
        ],
        "References" => "references.md",
        "Thanks" => "thanks.md"
    ]
)

deploydocs(
    repo = "github.com/JeffreySarnoff/WindowedFunctions.jl.git",
    target = "build"
)
