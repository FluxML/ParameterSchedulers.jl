using Pkg

Pkg.develop("..")

using Publish
using ParameterSchedulers
using Artifacts, LazyArtifacts

# override default theme
Publish.Themes.default() = artifact"flux-theme"

p = Publish.Project(ParameterSchedulers)

# needed to prevent error when overwriting
rm("dev", recursive = true, force = true)
rm(p.env["version"], recursive = true, force = true)

# build documentation
deploy(ParameterSchedulers; root = "/ParameterSchedulers.jl", force = true, label = "dev")