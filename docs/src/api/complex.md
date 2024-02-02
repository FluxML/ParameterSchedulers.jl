# Complex schedule API reference

```@autodocs
Modules = [ParameterSchedulers]
Pages = ["complex.jl"]
Filter = f -> !(f === ParameterSchedulers.Stateful) &&
              !(f === ParameterSchedulers.next!) &&
              !(f === ParameterSchedulers.reset!)
```
