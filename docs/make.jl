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
        "Options" => Any[
            "padding"=>"approach/padding.md",
            "atend"=>"approach/atend.md",
            "weights" => "approach/weights.md",
            "datastreams" => "approach/datastreams.md"
        ],
        "Uses" => Any[
                "rolling" => "use/rolling.md",
                "tiling"=>"use/tiling.md",
                "running"=>"use/running.md",
                "datastreams" => "use/datastreams.md"
        ],
        "References" => "references.md",
        "Thanks" => "thanks.md"
    ]
)

deploydocs(
    repo = "github.com/JeffreySarnoff/WindowedFunctions.jl.git",
    target = "build"
)
