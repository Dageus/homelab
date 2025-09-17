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

To setup a HTTPS connection to Vaultwarden, choose one of the reverse proxies/HTTPS providers:

- [Caddy](../caddy/README.md)

- [Nginx-Proxy-Manager](../npm/README.md)

- [Traefik](../traefik/README.md)

### Setting up Admin page

To enable the admin page, we need to define an environment variable in the `docker-compose.yml` called `ADMIN_TOKEN`. It can be anything, but it's better to use a long random string.

To generate it, we use `openssl`:

```bash
openssl rand -base64 48
```

For extra security, we can hash the admin token. This can be done using `vaultwarden hash`, but we need to connect to the container first. We can do this using `docker exec`:

```bash
docker exec -it <container_name> /vaultwarden hash
```

it will prompt you to enter a password, which afterwards your token will be presented to you

after generating the token, when you put it in the compose file, you need to escape the 5 `$` occurrences, using the 2 `$`.

```yaml
  environment:
    ADMIN_TOKEN: $$argon2id$$v=19$$m=19456,t=2,p=1$$UUZxK1FZMkZoRHFQRlVrTXZvS0E3bHpNQW55c2dBN2NORzdsa0Nxd1JhND0$$cUoId+JBUsJutlG4rfDZayExfjq4TCt48aBc9qsc3UI
```

#### NOTE

If you are using a `.env` file to save the admin token, you don't need to escape the `$`:

```sh
VAULTWARDEN_ADMIN_TOKEN='$argon2id$v=19$m=65540,t=3,p=4$MmeK.....'
```

You just need to call the variable in the `docker-compose.yml`:

```yaml
    environment:
      - ADMIN_TOKEN=${VAULTWARDEN_ADMIN_TOKEN}
```

You can check if the variable is correctly loaded using:

```bash
docker compose config
```

## Setting up SMTP

#### Sources

[https://github.com/dani-garcia/vaultwarden/wiki/SMTP-Configuration](https://github.com/dani-garcia/vaultwarden/wiki/SMTP-Configuration)

[https://www.reddit.com/r/web_design/comments/184p4xb/how_do_i_get_email_with_my_domain/](https://www.reddit.com/r/web_design/comments/184p4xb/how_do_i_get_email_with_my_domain/)

### Using Gmail OAuth

##### Sources

[https://support.google.com/accounts/answer/185833?hl=en&ref_topic=7189145](https://support.google.com/accounts/answer/185833?hl=en&ref_topic=7189145)

You'll have to generate an App Password for Vaultwarden to be able to send e-mail through your account


### Using own domain

#### Email routing through Cloudflare

If you're using Cloudflare like me, you can set up Email Routing, which tells Cloudflare: 

> Every email that gets sent to <email>@<my.domain> gets redirected to <myemail>@gmail.com

First, go to [https://www.cloudflare.com/developer-platform/products/email-routing/](https://www.cloudflare.com/developer-platform/products/email-routing/) and click on "Get Started" or simply go to your dashboard, and click on your domain, and you'll see on the dash on the left an `Email` section, click it and choose `Email Routing`.

Then, simply add the email address you want to create, and have it redirect to any other account you want that you own. Click on "Create and Continue". You will then received an email on the routed account to verify it; once you've done it, click "Continue".

You will probably have some conflicting configuration in your DNS that doesn't allow Cloudflare to correctly route the emails to your account. Simply delete these entries and click on "Add records and enable".

And you're done! It's that easy

#### Using Zoho

[Zoho](https://www.zoho.com/) allows up to 5 free accounts on their service, which is perfect for us.

For it to allow us to use our custom domain, we need to use the "Business Email" option when you visit [https://mail.zoho.com/signup?type=org&plan=free](https://mail.zoho.com/signup?type=org&plan=free)

Fill it with your information:

- `Name`: instead of using a company name, just use your name.

- `Email Address / Mobile Number`: a valid, existing mail address or a mobile phone number

and create a password for your account.

### Sending e-mails

The best service to use is [SMTP2GO](https://www.smtp2go.com/)

Head on over to their page and click "Try SMTP2GO Free" and add your newly created personal email address.

Once again, we're going to just use our name as the company name because why not and then fill the rest of the information as you normally would.

After verifying your account, go to your email account to see the verification email they just sent you.

Wait a few seconds for them to verify the account, and afterwards, you're done!

Then, to actually send email's, you'll need to configure a verified sender.

The SMTP2GO admin dashboard has a neat TODO list once you create your account to set up everything.

Once everything is set up, the last step is to tell Vaultwarden to use your SMTP2GO account to send emails.

#### Verified senders

This part isn't so obvious. To verify your sender, you need to alter your DNS settings.

Go to the "Verified Senders" section in your SMTP2GO dash and click on your domain. This will open the configuration for the sender.

You'll probably see the DNS configuration with some red question marks, this means these CNAME records still aren't set in your DNS provider.

So, go to your Cloudflare dashboard DNS section. 

- Click on "Add Record".

- Choose "CNAME" as the type

- Copy the "hostname" from SMTP2GO and paste it in the "name" section of the CNAME.

- Copy the "content" from SMTP2GO and paste it in the "target" section of the CNAME.

- Set the "Proxy status" to "DNS only", otherwise SMTP2GO won't be able to find the entries.

Do this for each of the CNAME entries listed in "DNS Configuration" in SMTP2GO.

---

If your docker is yet to be deployed, you can use

#### Docker

```sh
docker run -d --name vaultwarden \
  -e SMTP_HOST=smtp.domain.tld \
  -e SMTP_FROM=vaultwarden@domain.tld \
  -e SMTP_PORT=587 \
  -e SMTP_SECURITY=starttls \
  -e SMTP_USERNAME=myusername \
  -e SMTP_PASSWORD=MyPassw0rd \
  -v /vw-data/:/data/ \
  -p 80:80 \
  vaultwarden/server:latest
```

#### Docker-compose

check the [docker-compose.yml](./docker-compose.yml) example.

---

If your application is already live, head on over to your admin page -> SMTP settings and use the values from the user you just created on the settings (the host is "mail.smtp2go.com").

After saving your settings, you can try sending an email to any account you own, if everything goes correctly, you'll have received the email and the setup is ready!
