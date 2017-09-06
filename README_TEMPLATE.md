[![Build Status](https://api.travis-ci.org/wallix/awless-templates.svg?branch=master)](https://travis-ci.org/wallix/awless-templates)

[Twitter](http://twitter.com/awlessCLI) | [Wiki](https://github.com/wallix/awless/wiki) | [Changelog](https://github.com/wallix/awless/blob/master/CHANGELOG.md#readme)

# awless templates

Repository to collect official, verified and runnable templates for the [awless CLI](https://github.com/wallix/awless)

**You need at least awless version v0.1.3 to run those examples**

Here are some non exhaustive [Examples](https://github.com/wallix/awless/wiki/Examples) of what you can do with templates. You can also read more about [awless templates](https://github.com/wallix/awless/wiki/Templates)

## Continuous Integration

On each change all templates are verified & compiled against the latest version of `awless`.

You can run the verification locally with:

    go get github.com/wallix/awless  # if needed
    go test -v

# Examples

{{range $index, $example := .}}
* [{{$example.Title}}](#{{ MarkdownTitleLink $example.Title }}){{end}}

{{range $index, $example := .}}
### {{$example.Title}}

{{if $example.MinimalVersion }}
**-> Minimal awless version required: {{ $example.MinimalVersion }}**
{{ end }}

{{if $example.Description }}
*{{ $example.Description }}*
{{ end }}

{{if $example.Tags }}
**tags**: 
{{ Join $example.Tags ", " }}
{{ end }}


{{$example.Documentation}}

Run it locally with: `awless run repo:{{$example.Name}} -v`

{{if $example.CLIExample }}
Full CLI example:
```sh
{{ $example.CLIExample }}
```
{{ end }}

{{end}}