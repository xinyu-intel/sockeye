# Sockeye @ WNMT18

This directory contains scripts and documentation for running Sockeye and other tools via nvidia-docker.  It is recommended that you **copy this directory outside of the sockeye directory** and use it as your base work directory.  Running everything inside of the sockeye code directory will interfere with Docker builds.

## Environment

The base computing environment requires nvidia-docker and its dependencies.  The easiest way to get started is with the AWS Deep Learning AMI.  To use your own environment, follow the directions [here](https://github.com/NVIDIA/nvidia-docker) to install nvidia-docker and skip the rest of this section.

To get started with AWS, start a new GPU instance (p3 series) using the Deep Learning Base AMI (Ubuntu) Version 3.0.  Then run the following to install nvidia-docker:

```
sudo apt-get update && sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -

curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update

sudo apt-get update && sudo apt-get install -y docker-ce nvidia-docker2

sudo pkill -SIGHUP dockerd

sudo usermod -aG docker $USER
```

Log out and back in.

Run the following to ensure nvidia-docker is installed correctly:

```
nvidia-docker run --rm nvidia/cuda nvidia-smi
```

## Sockeye Docker Image

To build a Docker image containing Sockeye and other necessary software, run the build script from the root of the sockeye directory:

```
./docker/build.sh
```

**IMPORTANT**: If you update the Sockeye code, commit the changes to your git repository and re-run the build script.  Sockeye images are tagged by commit and a change of commit tells the build script to update the Sockeye installation in the Docker image.  The development cycle is: make changes, commit, re-run build script, run experiments.

## Training Pipeline

This task uses pre-processed training data so the pipeline consists of only a few steps.  Again, it is recommended that you **copy this directory outside of the sockeye directory** and run experiments there.

First, download the training data files:
```
./download_data.sh
```

Next, learn a byte-pair encoding model and encode the data:
```
./bpe_encode_data.sh
```

To use Sockeye's vocabulary selection capability, learn a `fast_align` lexical table and convert it to a tok-K lexicon file:
```
./
```
