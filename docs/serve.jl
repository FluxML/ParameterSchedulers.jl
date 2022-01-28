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

# serve documentation
serve(ParameterSchedulers)