# Seattle Central College Project 2019
The intention of this project is to allow a user to set up a fully functional gitlab instance on a new GKE cluster from Google Cloud Shell with only minimal interaction. This is intended to be run from the cloud shell while in a fresh GCP project. This will likely work inside an existing project but it's not garaunteed.

## Instructions
Start the process from the home directory of your Cloud Shell by copy and pasting the following command. Everything else should take care of itself:

```bash
cd
curl https://raw.githubusercontent.com/WarpRat/capstone/master/bootstrap.sh > ~/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
```

## Limitations
Although GKE documentation suggests using a wildcard DNS service like xip.io or nip.io to get letsencrypt certificates without having to register a domain name and set up DNS, in practice this is nearly impossible. Letsencrypt limits certificates to 50 per week per domain. Since xip.io and nip.io are popular global services this limit has almost certainly been reached at any given time. In the future this project will be updated to allow the user to supply a domain name that is controlled by GCP's DNS service to make the entire deployment seamless.
