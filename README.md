# Heroku Logger

A graphic interface made in Rails for displaying and analyzing log files from [elasticsearch](https://en.wikipedia.org/wiki/Elasticsearch).

Keep in mind this was made to consume logs from an application that runs on the [Heroku Platform](https://www.heroku.com/), so you might face some problems consuming logs from somewhere else as Heroku logs do not conform with RFC5424 standards.

## How to setup
I chose to deploy the service with kubernetes on [Google Cloud Platform](https://cloud.google.com) and you can do so very easily as the kubernetes resource files are all set up. If you choose to do that, follow this steps:

Substitute $YOUR_GCP_PROJECT by the id of your project on GCP.

Create a [kubernetes secret](https://kubernetes.io/docs/concepts/configuration/secret/) to setup the following env vars for the web application:
- **ELASTICSEARCH_URL**: http://your-elasticsearch-service-ip:9200
- **SECRET_KEY_BASE**: result of running ```rake secret```
- **DASHBOARD_PASSWORD**: string of your choice to authenticate before accessing the dashboard

Create the kubernetes resources(deployment and services for the elasticsearch instance and the Rails application).

For an application that runs on Heroku, run:
``` bash
heroku drains:add https://yourdomain.com/logs -a your-application
```

That's it. Heroku will start to send HTTPS requests to the web application, that will create the logs and display them on the only HTML route available('/').

## Further details and considerations

As of now, the elasticsearch instance deployed with this project has no security, so feel free to make a pull request and fix that.

You will need to use a domain because Heroku only allows log drain to HTTPS. Just point your domain to the IP that the heroku-logger service comes up with.

Learn more about the way Heroku allows us to consume the logs https://devcenter.heroku.com/articles/log-drains
