using Documenter, WindowedFunctions

makedocs(
    modules = [WindowedFunctions],
    sitename = "WindowedFunctions.jl",
    authors = "Jeffrey Sarnoff",
    pages = Any[
        "Overview" => "index.md",
        "Datastores and Buffering" => "store_and_supply.md",
        "Available Functions" => "rapplicables.md",
        "References" => "references.md",
    ]
)

deploydocs(
    repo = "github.com/DiademSpecialProjects/WindowedFunctions.jl.git",
    target = "build"
)