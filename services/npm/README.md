# Nginx Proxy Manager (NPM)

Nginx-Proxy-Manager served a very specific purpose in my homelab setup.

Since I used Cloudflare Tunnel to connect (most of) my apps, I thought there was no need for a proxy manager.

But since I deployed a XPEnology on a VM (see the guide [here](../xpenology/README.md)) for my family, I wanted an easy but secure way for them to access it. This is where NPM came in.

And I also noticed it's better to have something private when it can be, instead of risking it by putting on the WAN, despite being protected by Cloudflare.

The setup involved 2 things: Tailscale (or Wireguard) and NPM.

In this case, I used my homelab tailscale node as a subnet router to my home network, and used the same domain I had registered in cloudflared, but this time, it was NPM resolving the address.

This provided an easy way for non tech-savvy people (a.k.a. my family) to access our home NAS.

### Repo

[https://github.com/NginxProxyManager/nginx-proxy-manager](https://github.com/NginxProxyManager/nginx-proxy-manager)

### Website

[https://nginxproxymanager.com/](https://nginxproxymanager.com/)

### Link for Certificate Renewal

[https://www.digitalocean.com/community/tutorials/how-to-create-let-s-encrypt-wildcard-certificates-with-certbot](https://www.digitalocean.com/community/tutorials/how-to-create-let-s-encrypt-wildcard-certificates-with-certbot)

## Cons

Let's get this out of the way. My biggest pet peeve against NPM is the fact that it's **imperative**.

Although Traefik is declarative, it isn't as versatile as NPM, so the only choice I have is to eventually use Ansible and NPM's API to make my proxies declarative, which is unfortunate.

## Guide

First of all, deploy the NPM docker container and go to it's LXC IP and port on a browser to access the web interface (to see the LXC IP go to the container dashboard on proxmox, and to see the port, go to the [docker-compose](./docker-compose.yml).

You will be prompted to login.

### Login Credentials

the default login credentials are:

- email: admin@example.com
- password: changeme

## DNS-01 Challenge (Cloudflare)

#### Source

[https://www.reddit.com/r/unRAID/comments/kniuok/howto_add_a_wildcard_certificate_in_nginx_proxy/](https://www.reddit.com/r/unRAID/comments/kniuok/howto_add_a_wildcard_certificate_in_nginx_proxy/)

If you are using Cloudflare Zero Trust and a Cloudflare tunnel, you can have HTTPS in your LAN by using a DNS Challenge and **NO** ports open.

If you just have a regular public Domain obtained from a different provider, you'll need to forward ports 80 and 443 in your router.

Access you Cloudflare Dashboard, then:

- Go to Profile (top right corner in the Dashboard)

- API Tokens

- Create Token

- Create Custom Token (bottom of the page)

- Give a name to your token

- Permissions are: **Zone** -> **DNS** -> **Edit**

- Choose a TTL that ends in the far future so you don't have to worry about it

- Click "Continue to summary"

- Click "Create Token"

- Copy the API Token to your clipboard (**DO NOT LOSE IT, OTHERWISE YOU NEED TO REPEAT THE WHOLE PROCESS**)

---

Go to you NPM, and navigate to "SSL Certificates" in the navbar.

- Click "Add SSL Certificate" -> Let's Encrypt

- Add your local DNS wildcard Domain Name (like "*.home.example.com" or whatever you like)

- Add an email address to Let's Encrypt (I used the same as the NPM)

- Enable "Use DNS Challenge"

- Choose Cloudflare as your DNS Provider

- Paste the API Token you previously created in the textbox next to `dns_cloudflare_api_token=`

- Agree to Let's Encrypt's Terms of Service

- Click save and wait for a few seconds while it creates the Certificate

Afterwards, you can add this certificate to all your hosts, and for extra security, you can enable "Force SSL" and "Use HTTP/2"

And boom, you have HTTPS inside your LAN, no more hassles about unsecure connections in your browser, or the danger of MITM attacks, even inside your own home, and even better, no open ports.

## Self-signed certificate (Manual)

#### Source

[https://www.reddit.com/r/nginxproxymanager/comments/15rpcg6/npm_for_local_network_only_and_wireguard/](https://www.reddit.com/r/nginxproxymanager/comments/15rpcg6/npm_for_local_network_only_and_wireguard/)

[https://stackoverflow.com/questions/10175812/how-can-i-generate-a-self-signed-ssl-certificate-using-openssl](https://stackoverflow.com/questions/10175812/how-can-i-generate-a-self-signed-ssl-certificate-using-openssl)

If you like messing with bash commands, this is gonna be fun!

First, we have to generate our certificate. The easiest way to do this is using `openssl`:

```bash
openssl req -new -newkey rsa:2048 -sha256 -days 7300 -nodes -x509 -keyout npm.key -out npm.crt
```

this basically asks openssl to create a new certificate for us, and will return 2 files:

- the key, `npm.key`

- and the certificate itself, `npm.crt`

for the RSA, you can also use 4096 or even 8192 bits for the keys if you really want to make it unbreakable

the `-nodes` (short for "no DES") tells openssl you don't want to password protect your private key, otherwise it will ask you for a passkey with at least 4 characters

`-days 7300` makes the certificate valid for 20 years, just so you don't have to worry about it.

### Important Note

if you want to make this a wildcard certificate, during the interactive form, declare your wildcard domain in the `Common Name` section

```
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:
State or Province Name (full name) [Some-State]:
Locality Name (eg, city) []:
Organization Name (eg, company) [Internet Widgits Pty Ltd]:
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:*.<your_domain>.com         <----- Define your domain/wildcard here!
Email Address []:joao.miguel.abreu.nogueira@gmail.com
```

---

Go to you NPM, and navigate to "SSL Certificates" in the navbar.

- Click "Add SSL Certificate" -> Custom

- Give it a name, like "LAN SSL Certificate"

- Upload the .key and .cert files in their respective place

- Note that for self-signed certificates you **don't** need an intermediate certificate

Then just fill your proxy host as you normally would, but enable the following options in the SSL tab:

- Force SSL

- HSTS Enabled

- HTTP/2 Support

Then add the domain name you want (remember it nees to match the wildcard certificate you just made) and save it.

When you click on it, you might receive a warning (since it's a self-signed certificate) but just add an exception to your browser and you'll no longer have it, it's just a one time hassle.

And now you have HTTPS inside your LAN, with your own self-signed certificate!
