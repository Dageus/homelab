# Vaultwarden

Vaultwarden is an alternative to [Bitwarden](https://bitwarden.com/), written in Rust for self-hosted environments, that is compatible with official Bitwarden clients and has the same features, enabling you to have all the benefits of Bitwarden and its password managing capabilities at home.

It comes built-in with many useful features, specially if you want to "de-Google" yourself as many people are trying nowadays:

- Authenticator

- Personal Vault

- Support for YubiKey

- End-to-end encrypted text (Send)

and many more, if you check their repo they have a very comprehensive guide on top of the already existing Bitwarden documentation.

## Repo

[https://github.com/dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden)

## Guide

#### Sources

[https://github.com/dani-garcia/vaultwarden/wiki](https://github.com/dani-garcia/vaultwarden/wiki)

When you launch Vaultwarden for the first time and try to access it on the web, you might be a bit disappointed, because it seems it just keeps loading forever... and that's because we haven't setup a certificate for it.
Vaultwarden can only use its cryptographic capabilities if you have a secure connection to it.

TODO: TALK ABOUT HOW TO ACCESS ADMIN SERVICE, AND HOW TO CHANGE THE DOMAIN IN THE ENVIRONMENT VARIABLE

### Setting up SMTP
