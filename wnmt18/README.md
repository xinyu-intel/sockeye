# Sockeye @ WNMT18

This directory contains scripts and documentation for running a Sockeye pipeline for the 2018 Workshop on Neural Machine Translation shared task.

To check out the branch of Sockeye for this workshop, run:

```
git clone git@github.com:awslabs/sockeye.git -b wnmt18 sockeye-wnmt18
```

## Environment

The base computing environment requires nvidia-docker and its dependencies.  The easiest way to get started is with the AWS Deep Learning AMI.  To use your own environment, install [CUDA](https://developer.nvidia.com/cuda-downloads) and [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) and skip the rest of this section.

To get started with AWS, start a new GPU instance (p3 series, we recommend p3.8xlarge) using the Deep Learning Base AMI (Ubuntu) Version 3.0.  **We recommend increasing the root volume size from 50 to 500 GB (Step 4: Add Storage).**  Run the following to install nvidia-docker:

```
sudo apt-get update && sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey \
  |sudo apt-key add -

curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list \
  |sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y docker-ce nvidia-docker2

sudo pkill -SIGHUP dockerd

sudo usermod -aG docker $USER

sudo reboot
```

Log back in after the instance restarts and run the following to ensure nvidia-docker is installed correctly:

```
docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
```

## Sockeye Docker Image

**IMPORTANT**: These images use Intel's Python and Math Kernel Library distributions.  Read over the license [here](https://software.intel.com/en-us/license/intel-simplified-software-license) and see the FAQ [here](https://software.intel.com/en-us/mkl/license-faq) before using.

To build a Docker image containing Sockeye and other necessary software, run the build script from the root of the sockeye directory.  There are currently two builds: one optimized for CPU and one optimized for GPU.  You can specify "cpu", "gpu", or both:

```
./docker/build.sh cpu gpu
```

**IMPORTANT**: If you update the Sockeye code, commit the changes to your git repository and re-run the build scripts.  Sockeye images are tagged by commit and a change of commit tells the build script to update the Sockeye installation in the Docker image.  The development cycle is: make changes, commit, re-run build script, run experiments.

## Training Pipeline

This task uses pre-processed training data so the pipeline consists of only a few steps.  Start by creating a work directory outside of the Sockeye directory.

```
mkdir work && cd work
```

### Data

This part only needs to be run once to set up training and test data.  First, download the training data files:

```
../sockeye-wnmt18/wnmt18/download_data.sh
```

Next, learn a byte-pair encoding model and encode the data:

```
../sockeye-wnmt18/wnmt18/bpe_encode_data.sh
```

Sockeye's vocabulary selection capability significantly speeds up decoding.  It depends on a `fast_align` lexical table that can be learned once and reused:

```
../sockeye-wnmt18/wnmt18/fast_align.sh
```

### Model Training

This part runs every time Sockeye is modified in a way that requires retraining the translation model.  First, **make sure you have built a Sockeye image with your latest code**.  These scripts use the `sockeye:latest-gpu` Docker image to run commands.

The training script uses Sockeye to learn a transformer model with settings similar to those in the paper [Sockeye: A Toolkit for Neural Machine Translation
](https://arxiv.org/abs/1712.05690).  This represents a system with high translation quality and some basic speed optimizations.  **Copy and modify the script as needed to run multiple experiments with different training settings.**

```
../sockeye-wnmt18/wnmt18/train.sh
```

### Evaluation

After training, evaluate the model for BLEU score and time.  The eval script uses good default decoding settings for CPU and GPU.  **Copy and modify the script as needed to run multiple experiments with different decoding settings.**  Call the script with "cpu", "gpu", or both to run an evaluation:

```
../sockeye-wnmt18/wnmt18/eval.sh cpu gpu
```

Results are written out to the "results" directory, including a "run" script that can be used for packaging.  For example:

```
results/baseline.default.gpu.run.sh
results/newstest2014.baseline.default.gpu
results/newstest2014.baseline.default.gpu.bleu
results/newstest2014.baseline.default.gpu.log
...
```

### Packaging

To package a model for the official evaluation (see [Procedure](https://sites.google.com/site/wnmt18/shared-task) section), run the package script with your selected image, model, run script, team name, and system name.  For instance:

```
../sockeye-wnmt18/wnmt18/package.sh sockeye:latest-cpu baseline results/baseline.default.cpu.run.sh my-team baseline
```

**IMPORTANT**: "latest" is a shortcut that always refers to the most recently built Sockeye image.  If your model ran with a different Sockeye image (or you aren't sure), check the decode log to find the commit of Sockeye.  Then run `docker images` to find the tag that matches the commit.
