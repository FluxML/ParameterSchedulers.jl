using ParameterSchedulers
using Documenter

makedocs(;
    modules=[ParameterSchedulers],
    authors="Kyle Daruwalla",
    repo="https://github.com/darsnack/ParameterSchedulers.jl/blob/{commit}{path}#L{line}",
    sitename="ParameterSchedulers.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://darsnack.github.io/ParameterSchedulers.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/darsnack/ParameterSchedulers.jl",
)
