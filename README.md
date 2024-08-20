# arxiv-sanity-physics

This is a fork of https://github.com/karpathy/arxiv-sanity-lite. It has two main differences:

1. It queries the [arXiv](https://arxiv.org) api for recent posts in gr-qc and hep-th. 

This was accomplished by changing one line in arxiv_daemon.py. In particular, we use the custom query

```
q = 'cat:gr-qc+OR+cat:hep-th'
```

2. I've added self-hosting infrastructure. In particular, I've included a Dockerfile that sets up the 
Flask server and also sets up a cronjob scheduled to run everyday. An example docker-compose.yaml might
be:

```
version: '3.8'

services:
  app:
    image: graveltr/arxiv-sanity-physics:v1.0
    container_name: arxiv-sanity-physics
    ports:
      - "5000:5000"
    volumes:
      - ./data:/app/data
    restart: always
```

This pulls my custom image from https://hub.docker.com/, port maps the necessary Flask port, and sets up a permanent volume to store the database and model parameters.

Once setup, the application is accessed via port 5000 at your hosting machine's ip. 

# arxiv-sanity-lite

A much lighter-weight arxiv-sanity from-scratch re-write. Periodically polls arxiv API for new papers. Then allows users to tag papers of interest, and recommends new papers for each tag based on SVMs over tfidf features of paper abstracts. Allows one to search, rank, sort, slice and dice these results in a pretty web UI. Lastly, arxiv-sanity-lite can send you daily emails with recommendations of new papers based on your tags. Curate your tags, track recent papers in your area, and don't miss out!

I am running a live version of this code on [arxiv-sanity-lite.com](https://arxiv-sanity-lite.com).

![Screenshot](screenshot.jpg)

#### To run

To run this locally I usually run the following script to update the database with any new papers. I typically schedule this via a periodic cron job:

```bash
#!/bin/bash

python3 arxiv_daemon.py --num 2000

if [ $? -eq 0 ]; then
    echo "New papers detected! Running compute.py"
    python3 compute.py
else
    echo "No new papers were added, skipping feature computation"
fi
```

You can see that updating the database is a matter of first downloading the new papers via the arxiv api using `arxiv_daemon.py`, and then running `compute.py` to compute the tfidf features of the papers. Finally to serve the flask server locally we'd run something like:

```bash
export FLASK_APP=serve.py; flask run
```

All of the database will be stored inside the `data` directory. Finally, if you'd like to run your own instance on the interwebs I recommend simply running the above on a [Linode](https://www.linode.com), e.g. I am running this code currently on the smallest "Nanode 1 GB" instance indexing about 30K papers, which costs $5/month.

(Optional) Finally, if you'd like to send periodic emails to users about new papers, see the `send_emails.py` script. You'll also have to `pip install sendgrid`. I run this script in a daily cron job.

#### Requirements

 Install via requirements:

 ```bash
 pip install -r requirements.txt
 ```

#### Todos

- Make website mobile friendly with media queries in css etc
- The metas table should not be a sqlitedict but a proper sqlite table, for efficiency
- Build a reverse index to support faster search, right now we iterate through the entire database

#### License

MIT
