### NVIDIA GPU/Tensor Core Accelerator for PyTorch, PyTorch Geometric, TF2, Tensorboard + OpenCV
A complete computer vision container that includes Jupyter notebooks with built-in code hinting, Miniconda, CUDA 11.8, TensorRT inference accelerator for Tensor cores, CuPy (GPU drop in replacement for Numpy), PyTorch, PyTorch Geometric for geomteric learning and/or Graph Neural Networks, TendorFlow 2, Tensorboard, and OpenCV (complied for CUDA) for accelerated workloads on NVIDIA Tensor cores and GPUs. <em>Roadmap:</em> Adding Dask for GPU based image preprosccing and pipelines, as well as model mgm't, and model serving and monitoring.

* There are working notebook examples on how to wire up, both Torch and TF2 to Tensorboard in ```/app``` folder.

-----------------------------------------------------------



-----------------------------------------------------------

### Features ###
- Miniconda: Accelerated Python, version 3.11
- CuPy: GPU accelerated drop in replacement for Numpy
- OpenCV, latest version which is made to compile for CUDA GPUs in the container. Depending upon your GPU you may have to change ```-DCUDA_ARCH_BIN=7.5``` in the OpenCV flags within the Dockerfile, and rebuild the image.
- PyTorch 2.0 with Torchvision for GPU, latest version
- PyTorch geometric for GNN's
- Captum to explain Torch models
- Tensorflow 2 with Keras
- Tensorboard for both Torch and TF2
- NVIDIA TensorRT inference accelerator for Tensor core access and CUDA 11 for GPUs
- Repo includes two working notebook examples on how to wire up Torch and TF2 to TensorBoard, located in ```/app``` folder

### Built in code hinting in Jupyter Notebook ###

Press tab to see what methods you have access to by clicking tab.

![jupyter-tabnine](https://raw.githubusercontent.com/wenmin-wu/jupyter-tabnine/master/images/demo.gif)


--------------------------------------------------------------------------------
### Before you begin (This might be optional) ###

Link to nvidia-docker2 install: [Tutorial](https://medium.com/@sh.tsang/docker-tutorial-5-nvidia-docker-2-0-installation-in-ubuntu-18-04-cb80f17cac65)

You must install nvidia-docker2 and all it's deps first, assuming that is done, run:


 ` sudo apt-get install nvidia-docker2 `
 
 ` sudo pkill -SIGHUP dockerd `
 
 ` sudo systemctl daemon-reload `
 
 ` sudo systemctl restart docker `
 
-----------------------------------------------------------------------------------


How to run this container:

### Step 1 ###

` docker build -t <container name> . `  < note the . after <container name>

If you get an authorized user from the docker pull cmd inside the container, try:

` $ docker logout `

...and then run it or pull again. As it is public repo you shouldn't need to login.

### Step 2 ###

Run the image, mount the volumes for Jupyter and app folder for your fav IDE, and finally the expose ports `8888` for Jupyter Notebook:


` docker run --rm -it --gpus all --user $(id -u):$(id -g) --group-add container_user --group-add sudo -v "${PWD}:/app" -p 8888:8888 -p 6006:6006 <container name> `

:P If on Windows 10:

` winpty docker run --rm -it --gpus all -v "/c/path/to/your/directory:/app" -p 8888:8888 -p 6006:6006 <container name> `

 <em>Disclaimer:</em> You should be able to utilize the runtime argument on Docker 19+ as long as it is installed and configured in the daemon configuration file:

 
Install nvidia-docker2 package
https://github.com/nvidia/nvidia-docker/wiki/Installation-(version-2.0)#ubuntu-distributions-1


### Step 3: Check to make sure GPU drivers and CUDA is running ###

- <strong>Open another ssh tab</strong>, and exec into the container and check if your GPU is registering in the container and CUDA is working:

- Get the container id:

` docker ps `

- Exec into container:

` docker exec -u root -t -i <container id> /bin/bash `

- Check if NVIDIA GPU DRIVERS have container access:

` nvidia-smi `

- Check if CUDA is working:

` nvcc -V `


### Initialize Tensorboard

- Exec into the container as stated above, and run the following:

`tensorboard --logdir=//app --bind_all `

- You will recieve output that looks somnething like this:

`TensorBoard 2.1.0 at http://af5d7fc520cb:6006/`

Just replace `af5d7fc520cb` with the word `localhost` and launch in the browser, then you will see:

![a](./misc/a.png)
![a](./misc/b.png)
![a](./misc/c.png)
![a](./misc/d.png)


--------------------------------------------------


### Known conflicts with nvidia-docker and Ubuntu ###

AppArmor on Ubuntu has sec issues, so remove docker from it on your local box, (it does not hurt security on your computer):

` sudo aa-remove-unknown `


### You may have to do this to get the NVIDIA container runtime to work

Install the the nvidia-conatiner-runtime package, install and set-up config is here: https://github.com/NVIDIA/nvidia-container-runtime.

` sudo apt-get install nvidia-container-runtime `

` sudo vim /etc/docker/daemon.json `

Then , in this `daemon.json` file, add this content:

```
{
  "default-runtime": "nvidia"
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
       "runtimeArgs": []
     }
  }
}
```

` sudo systemctl daemon-reload `

` sudo systemctl restart docker `
 

### Other misc troubleshooting

Method 2:
Install the container runtime:
https://github.com/NVIDIA/nvidia-container-runtime#ubuntu-distributions

Modify the config file:
https://github.com/NVIDIA/nvidia-container-runtime#daemon-configuration-file

--------------------------------------------------

