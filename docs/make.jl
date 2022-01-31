using Pkg

Pkg.develop(path = "..")
# this is needed since Publish v0.9 breaks our theming hack
Pkg.pin(name = "Publish", version = "0.8")

using Publish
using ParameterSchedulers
using Artifacts, LazyArtifacts

# override default theme
Publish.Themes.default() = artifact"flux-theme"

p = Publish.Project(ParameterSchedulers)

function build_and_deploy(label)
    # needed to prevent error when overwriting
    rm(label, recursive = true, force = true)
    rm(p.env["version"], recursive = true, force = true)

    # build documentation
    deploy(ParameterSchedulers; root = "/ParameterSchedulers.jl", label = label)
end
