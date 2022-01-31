using Pkg

Pkg.develop(path = "..")

using Publish
using ParameterSchedulers
using Artifacts, LazyArtifacts

# override default theme
cp(artifact"flux-theme", "../_flux-theme"; force = true)

build_and_deploy(label) =
    deploy(ParameterSchedulers; root = "/ParameterSchedulers.jl", label = label)
