using Publish
using ParameterSchedulers
using Artifacts

# override default theme
Publish.Themes.default() = artifact"flux-theme"

p = Publish.Project(ParameterSchedulers)

# serve documentation
serve(ParameterSchedulers)