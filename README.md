# Azure IoT Edge with Custom DNS

Azure IoT Edge runtime using a custom DNS.

## Infrastructure

### 1 - Create the resources

Generate the test-only certificate chain:

```sh
bash scripts/generateCerts.sh
```

Deploy the resources:

```sh
terraform -chdir="infra" init
terraform -chdir="infra" apply -auto-approve
```

<details>
  <summary>(Optional) Upgrade IoT Hub certificate to V2 (DigiCert)</summary>

  ```sh
  az iot hub certificate root-authority set --hub-name "iot-bluefactory" --certificate-authority v2 --yes
  ```
</details>

Make sure the EdgeGateway has completed the installation:

```sh
# Connect to the IoT Edge VM
ssh edgegateway@<public-ip>

# Check if the cloud-init status is "done", otherwise wait with "--wait"
cloud-init status

# Confirm that the IoT Edge runtime has been installed
iotedge --version
```

Restart the VM to activate any Linux kernel updates:

```sh
az vm restart -n "vm-bluefactory-edgegateway" -g "rg-bluefactory"
```

### 2 - Check the DNS provisioning

```sh
# Connect to the DNS server
ssh dnsadmin@<public-ip>

# Check if the cloud-init status is "done", otherwise wait with "--wait"
cloud-init status

# Check the DNS installation
sudo systemctl status named
```

Restart the VM to activate any Linux kernel updates:

```sh
az vm restart -n "vm-dns-edgegateway" -g "rg-bluefactory"
```

### 3 - DNS Setup

Upload the config files to the remote DNS server:

```sh
bash ./scripts/uploadBind9Config.sh
```

Connect to the DNS server and run the config script:

```sh
sudo bash dnsConfig.sh
```

Check the service status:

```sh
sudo systemctl status named
```

Testing the DNS resolution:

```sh
# Testing the local DNS
dig @10.0.90.4 dns.bluefactory.local

# Testing the EdgeGateway
dig @10.0.90.4 edgegateway.bluefactory.local

# Testing the IoT Hub
dig @10.0.90.4 iot-bluefactory.azure-devices.net
```

(OPTIONAL) You can change the DNS in the operating systems if required.

Edit `/etc/resolv.conf` and change the DNS:

```
nameserver 10.0.90.4
```

### 2 - Register the IoT Edge device

Run the script to create the IoT Hub device registration:

> ⚠️ IoT Hub supports registering IoT Edge devices only through self-signed method (certificate thumbprint). For a CA-Signed configuration, you must implement device enrollment with DPS. See [this issue](https://github.com/MicrosoftDocs/azure-docs/issues/108363) for details.

```sh
bash scripts/registerEdgeGatewayDevice.sh
```

Upload the required configuration files to the EdgeGateway device:

```
bash scripts/uploadEdgeConfig.sh
```

Connect with SSH to the EdgeGateway and execute the configuration

```sh
sudo bash edgeConfig.sh
```

Verify the results:

```sh
sudo iotedge system status
sudo iotedge system logs
sudo iotedge check
```

### 3 - Deploy the modules

Now that the device is properly registered and connected with IoT Hub, create a deployment:

```sh
az iot edge deployment create --deployment-id "gateway" \
    --hub-name $(jq -r .iothub_name infra/output.json) \
    --content "@edgegateway/deployments/gateway.json" \
    --labels '{"Release":"001"}' \
    --target-condition "deviceId='EdgeGateway'" \
    --priority 10
```

To check the deployment in the EdgeGateway device:

```sh
iotedge list
```

Check and confirm that everything is OK:

```sh
sudo iotedge check
```