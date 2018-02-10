package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"github.com/wallix/awless/aws/spec"
	"github.com/wallix/awless/config"
	"github.com/wallix/awless/template"
	"github.com/wallix/awless/template/env"
)

func TestCompileAllTemplates(t *testing.T) {
	var files []string
	if indir, err := filepath.Glob(filepath.Join("*.aws")); err != nil {
		t.Fatal(err)
	} else {
		files = append(files, indir...)
	}
	if otherdirs, err := filepath.Glob(filepath.Join("**", "*.aws")); err != nil {
		t.Fatal(err)
	} else {
		files = append(files, otherdirs...)
	}

	templates := make(map[string]*template.Template)

	fileCount := len(files)
	for _, file := range files {
		b, err := ioutil.ReadFile(file)
		if err != nil {
			t.Fatal(err)
		}

		meta, err := parseTemplateMetadata(b)
		if err != nil {
			t.Fatalf("parsing template metadata: %s", err)
		}

		if meta.MinimalVersion != "" {
			comp, err := config.CompareSemver(config.Version, meta.MinimalVersion)
			if err != nil {
				t.Errorf("version from '%s' template: %s", file, err)
			}
			if comp < 0 {
				t.Logf("ignoring %s as at least %s version required\n", file, meta.MinimalVersion)
				fileCount--
				continue
			}
		}

		if tpl, err := template.Parse(string(b)); err != nil {
			t.Error(fmt.Errorf("cannot parse template '%s'\n\n%s\n%s", file, b, err))
		} else {
			templates[fmt.Sprint(file)] = tpl
		}
	}

	if fileCount != len(templates) {
		t.Fatal("compilation run only on all templates parsed successfully")
	}

	// to get deterministic order in which test are done
	var templateNames []string
	for k := range templates {
		templateNames = append(templateNames, k)
	}
	sort.Strings(templateNames)

	awsspec.DefaultImageResolverCache.Store("suselinux::sles-12:x86_64:hvm:ebs", []*awsspec.AwsImage{
		&awsspec.AwsImage{Id: "stub-1234567"},
	})
	awsspec.DefaultImageResolverCache.Store("canonical:ubuntu:xenial:x86_64:hvm:ebs", []*awsspec.AwsImage{
		&awsspec.AwsImage{Id: "stub-6543210"},
	})
	awsspec.DefaultImageResolverCache.Store("amazonlinux::hvm:x86_64:hvm:ebs", []*awsspec.AwsImage{
		&awsspec.AwsImage{Id: "stub-6543210"},
	})
	awsspec.DefaultImageResolverCache.Store("debian:debian:stretch:x86_64:hvm:ebs", []*awsspec.AwsImage{
		&awsspec.AwsImage{Id: "stub-45637289"},
	})
	awsspec.DefaultImageResolverCache.Store("redhat:rhel:7.4:x86_64:hvm:ebs", []*awsspec.AwsImage{
		&awsspec.AwsImage{Id: "stub-wuvebfoq"},
	})

	awsspec.CommandFactory = awsspec.MockAWSSessionFactory

	for _, name := range templateNames {
		tpl := templates[name]
		cenv := template.NewEnv().WithLookupCommandFunc(func(tokens ...string) interface{} {
			newCommandFunc := awsspec.MockAWSSessionFactory.Build(strings.Join(tokens, ""))
			if newCommandFunc == nil {
				return nil
			}
			return newCommandFunc()
		}).Build()
		cenv.Push(env.FILLERS, stubFillers)

		if _, _, err := template.Compile(tpl, cenv, template.NewRunnerCompileMode); err != nil {
			t.Fatalf("cannot compile template '%s'\n%s", name, err)
		} else {
			log.Printf("successfully parsed and compiled '%s'\n", name)
		}
	}
}

var stubFillers = map[string]interface{}{
	"instance.keypair":               "stub",
	"instance.type":                  "stub",
	"instance.image":                 "stub",
	"instance.min-number":            1,
	"instance.subnets":               "stub",
	"instance.max-number":            1,
	"group-name":                     "stub",
	"domain.name":                    "stub",
	"dbname":                         "stub",
	"dbhost":                         "stub",
	"dbuser":                         "stub",
	"dbpassword":                     "stubstub",
	"wordpress.vpc":                  "stub",
	"wordpress.subnets":              "stub",
	"wordpress.keypair":              "stub",
	"instances.securitygroup":        "stub",
	"availabilityzone.1":             "stub",
	"availabilityzone.2":             "stub",
	"availabilityzone.3":             "stub",
	"my.ssh.keypair":                 "stub",
	"ubuntu.image.id":                "stub",
	"instance.count":                 1,
	"ubuntu.ami":                     "stub",
	"ssh.keypair":                    "stub",
	"role.name":                      "stub",
	"instance.subnet":                "stub",
	"instance.name":                  "stub",
	"vpc.cidr":                       "10.0.0.0/24",
	"vpc.name":                       "stub",
	"first.subnet.availabilityzone":  "stub",
	"first.subnet.cidr":              "10.0.0.0/24",
	"first.subnet.name":              "stub",
	"second.subnet.name":             "stub",
	"second.subnet.availabilityzone": "stub",
	"second.subnet.cidr":             "10.0.0.0/24",
	"dbsubnetgroup.description":      "stub",
	"dbsubnetgroup.name":             "stub",
	"elasticip.domain":               "stub",
	"keypair.name":                   "stub",
	"securitygroup.protocol":         "stub",
	"user.console-password":          "stubstub",
	"user.name":                      "stub",
	"awless.role-name":               "stub",
	"instance.distro":                "suselinux",
	"remoteaccess-cidr":              "10.0.0.0/24",
	"role-name":                      "stub",
	"aws-service":                    "stub",
	"aws-account-id":                 "stub",
	"assume-policy-name":             "stub",
	"scalinggroup.desired-capacity":  1,
	"instance.userdata":              "stub",
	"database.name":                  "stub",
	"office.ip":                      "127.0.0.1",
	"debian.image":                   "stub",
	"my.keypair":                     "stub",
	"database.username":              "stub",
	"database.identifier":            "stub",
	"password.minimum8chars":         "stubstub",
	"instance.vpc":                   "stub",
	"securitygroup.description":      "stub",
	"awless-scheduler.role-name":     "stub",
	"instance.tagvalue":              "stub",
	"instance.securitygroup":         "stub",
	"instance.tagkey":                "stub",
	"remote-access.cidr":             "10.0.0.0/24",
	"redhat-ami":                     "stub",
	"zookeeper.instance.type":        "stub",
	"broker.instance.type":           "stub",
	"subnet.cidr":                    "10.0.0.0/24",
	"subnet.vpc":                     "stub",
	"subnet.name":                    "stub",
	"vpc.internetgateway":            "stub",
	"image.description":              "stub",
	"image.bucket":                   "stub",
	"image.filepath":                 "./verifyall_test.go",
	"subnet1.zone":                   "stub",
	"subnet2.zone":                   "stub",
	"launchconfiguration.image":      "stub",
	"public.subnet":                  "stub",
	"securitygroup.for.instance":     "stub",
}
