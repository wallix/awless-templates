# awless templates

Repository **in progress** to collect official, verified and runnable templates for the [awless CLI](https://github.com/wallix/awless)

Here are some non exhaustive [Examples](https://github.com/wallix/awless/wiki/Examples) of what you can do with templates

You can read more about [awless templates](https://github.com/wallix/awless/wiki/Templates)

## CI / Test

By running the following command we ensure all templates in this repo can compile against the vendored `awless` lib:

    go test verifyall_test.go -v
