using Pkg

Pkg.develop(path = "..")

using Publish
using ParameterSchedulers
using Artifacts, LazyArtifacts

# override default theme
cp(artifact"flux-theme", "../_flux-theme"; force = true)

p = Publish.Project(ParameterSchedulers)

# serve documentation
serve(ParameterSchedulers)