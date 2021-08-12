# streamlit-run

This is sample-codes for [Streamlit](https://streamlit.io/) apps on Cloud Run with Identity-Aware Proxy (IAP).

![streamlit-run](https://github.com/tosh223/streamlit-run/blob/main/drawio/streamlit-run.png)

## Usage

1. Create a `terraform.tfvars` file.

    ```
    project                  = "****************"
    region                   = "us-central1"
    zone                     = "us-central1-a"
    iap_client_id            = "****************"
    iap_client_secret        = "****************"
    lb-domain                = "your.domain.com"
    iapHttpsResourceAccessor = "set a google account"
    ```

1. Execute commands below.

    ```sh
    make build-gcr
    cd ./terraform
    terraform plan
    terraform apply
    ```

1. Set the IP address output as `load_balancer_ip` to DNS that manages your domain.
