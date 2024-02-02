using Documenter, ParameterSchedulers
using Markdown

# copy readme into index.md
open(joinpath(@__DIR__, "src", "index.md"), "w") do io
    # wrap table html syntax in @raw blocks
    # unwrap then rewrap @raw blocks around @examples
    parse_table = false
    within_codeblock = false
    for line in readlines(joinpath(@__DIR__, "..", "README.md"); keep=true)
        clean_line = strip(line)
        if parse_table
            if clean_line == "```@example"
                within_codeblock = true
                write(io, "```\n")
                write(io, line)
            elseif clean_line == "```"
                within_codeblock = false
                write(io, line)
                write(io, "```@raw html\n")
            elseif clean_line == "</table>"
                parse_table = false
                write(io, line)
                write(io, "```\n")
            else
                # optionally run more markdown parsing
                if within_codeblock || startswith(clean_line, "<")
                    write(io, line)
                else
                    html(io, Markdown.parse(line))
                end
            end
        else
            if clean_line == "<table>"
                parse_table = true
                write(io, "```@raw html\n")
                write(io, line)
            else
                write(io, line)
            end
        end
    end
end

makedocs(;
    modules = [ParameterSchedulers],
    sitename = "ParameterSchedulers.jl",
    pages = [
        "Home" => "index.md",
        "Schedule cheatsheet" => "cheatsheet.md",
        "Tutorials" => [
            "tutorials/getting-started.md",
            "tutorials/basic-schedules.md",
            "tutorials/optimizers.md",
            "tutorials/complex-schedules.md",
            "tutorials/warmup-schedules.md"
        ],
        "Schedule interface" => "interface.md",
        "API reference" => [
            "api/general.md",
            "api/decay.md",
            "api/cyclic.md",
            "api/complex.md"
        ],
    ],
    warnonly = [:example_block, :missing_docs, :cross_references],
    format = Documenter.HTML(canonical = "https://fluxml.ai/ParameterSchedulers.jl/stable/",
                             assets = ["assets/flux.css"],
                             prettyurls = get(ENV, "CI", nothing) == "true")
)

deploydocs(; repo = "github.com/FluxML/ParameterSchedulers.jl.git", target = "build",
             push_preview = true)
