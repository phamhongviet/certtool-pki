# certtool-pki
Simple PKI using GNU-TLS certtool

## Require
gnutls

## Root CA Certificate

Generate:

    make root-ca

## Intermediate CA Certificate

Generate:

    make intm-ca

## User Identity Certificate

Generate user identity certificate for someone, together with their private key:

    make user-id-cert-key name=someone

User can also generate and keep their own private key, CA admin only need the CSR file:

    make user-id-csr name=someone

CA admin sign the certificate for user:

    make user-id-cert-key name=someone

## Server/Service Certificate

Generate server or service with domain something.example.com:

    make serv-cert name=something

## Node Identity Certificate

Generate node identity certificate with domain something.example.com, and IP address 192.168.6.9:

    make node-id-cert name=something ip_address=192.168.6.9

Node identity certificates are suitable for applications with node to node encryption such as Kubernetes, ElasticSearch or Vault.
