using Publish
using ParameterSchedulers

p = Publish.Project(ParameterSchedulers)

# needed to prevent error when overwriting
rm("dev", recursive = true, force = true)
rm(p.env["version"], recursive = true, force = true)

# build documentation
deploy(ParameterSchedulers; root = "/ParameterSchedulers.jl", force = true, label = "dev")