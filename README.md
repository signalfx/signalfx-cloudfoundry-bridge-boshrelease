> # :warning: End of Support (EoS) Notice
> **The SignalFx Cloud Foundry Bridge and SignalFx Smart Agent have reached End of Support.**
>
> The [Splunk Distribution of OpenTelemetry Collector for Pivotal Cloud Foundry](https://github.com/signalfx/splunk-otel-collector/tree/main/deployments/cloudfoundry) is the successor.

>ℹ️&nbsp;&nbsp;SignalFx was acquired by Splunk in October 2019. See [Splunk SignalFx](https://www.splunk.com/en_us/investor-relations/acquisitions/signalfx.html) for more information.

# SignalFx Bridge BOSH Release

This is a BOSH release for the [SignalFx
Bridge](https://github.com/signalfx/signalfx-cloudfoundry-bridge) app to get metrics from a
Cloud Foundry environment.  If you are using Pivotal Cloud Foundry, you should
probably use the tile that is also generated from this repository.


## Properties

The properties in the [spec file for the signalfx_bridge
job](https://github.com/signalfx/signalfx-cloudfoundry-bridge-boshrelease/blob/master/jobs/signalfx-bridge/spec)
correspond one-to-one to the properties described in the
[Configuration](https://github.com/signalfx/signalfx-cloudfoundry-bridge#configuration)
section of the SignalFx Bridge application repo.

