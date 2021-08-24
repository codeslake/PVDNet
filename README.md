# PVDNet: Pixel Volume-based Video Debluring Network
![License CC BY-NC](https://img.shields.io/badge/license-GNU_AGPv3-blue.svg?style=plastic)

<p align="center">
   <img src="./assets/network.jpg" />
</p>

This repository contains the official PyTorch implementation of the following paper:

> **[Recurrent Video Deblurring with Blur-Invariant Motion Estimation and Pixel Volumes](https://dl.acm.org/doi/pdf/10.1145/3453720)**<br>
> Hyeongseok Son, Junyong Lee, Jonghyeop Lee, Sunghyun Cho, Seungyong Lee, TOG 2021 (presented at SIGGRAPH 2021)

## About the Research
<details>
    <summary><i>Click here</i></summary>
    <h3> Overall Framework </h3>
    <p align="center">
    <img width=50% src="./assets/framework.jpg" />
    </p>
    <p>
        Our video deblurring framework consists of three modules: a blur-invariant motion estimation network (<i>BIMNet</i>), a pixel volume generator, and a pixel volume-based deblurring network (<i>PVDNet</i>).
        We first train <i>BIMNet</i>; after it has converged, we combine the two networks with the pixel volume generator.
        We then fix the parameters of <i>BIMNet</i> and train <i>PVDNet</i> by training the entire network.
    </p>
    <h3> Blur-Invariant Motion Estimation Network (<i>BIMNet</i>)</h3>
    <p>
        To estimate motion between frames accurately, we adopt <a "https://arxiv.org/pdf/1805.07036.pdf">LiteFlowNet</a> and train it with a blur-invariant loss so that the trained network can estimate blur-invariant optical flow between frames.
        We train <i>BIMNet</i> with a blur-invariant loss <img src="https://latex.codecogs.com/svg.latex?L_{BIM}^{\alpha\beta}" />, which is defined as (refer Eq. 1 in the main paper):
    <p>
    <p align="center">
        <img src="./assets/BIMNet_eq.svg" />
    </p>
    <p align="center">
        <img width=80% src="./assets/BIMNet_figure.jpg" />
    </p>
    <p>
        The figure shows a qualitative comparison of different optical flow methods.
        The results of the other methods contain severely distorted structures due to errors in their optical flow maps.
        In contrast, the results of BIMNets show much less distortions.
    </p>
    <h3> Pixel Volume for Motion Compensation </h3>
    <p>
        We propose a novel pixel volume that provides multiple candidates for matching pixels between images.
        Moreover, a pixel volume provides an additional cue for motion compensation based on the majority.
    </p>
    <p align="center">
        <img width=60% src="./assets/PV.jpg" />
    </p>
    <p>
        Our pixel volume approach leads to the performance improvement of video deblurring by utilizing the multiple candidates in a pixel volume in two aspects: 1) in most cases, the majority cue for the correct match would help as the statistics (Sec. 4.4 in the main paper) shows, and 2) in other cases, <i>PVDNet</i> would exploit multiple candidates to estimate the correct match referring to nearby pixels with majority cues.
    </P>
</details>


## Getting Started
### Prerequisites
*Tested environment*

![Ubuntu18.04](https://img.shields.io/badge/Ubuntu-16.0.4%20&%2018.0.4-blue.svg?style=plastic)
![Python 3.8.8](https://img.shields.io/badge/Python-3.8.8-green.svg?style=plastic)
![PyTorch 1.8.0](https://img.shields.io/badge/PyTorch-1.8.0%20&%201.9.0-green.svg?style=plastic)
![CUDA 10.2](https://img.shields.io/badge/CUDA-10.2%20&%2011.1-green.svg?style=plastic)

1. **Environment setup** 
    ```bash
    $ git clone https://github.com/codeslake/PVDNet.git
    $ cd PVDNet

    $ conda create -y --name PVDNet python=3.8 && conda activate PVDNet
    # for CUDA10.2
    $ sh install_CUDA10.2.sh
    # for CUDA11.1
    $ sh install_CUDA11.1.sh
    ```

2. **Datasets**
    * Download and unzip [Su *et al.*'s dataset](https://www.dropbox.com/s/8daduee9igqx5cw/DVD.zip?dl=1) and [Nah *et al.*'s dataset](https://www.dropbox.com/s/5ese6qtbwy7fsoh/nah.zip?dl=1) under `[DATASET_ROOT]`:

        ```
        ├── [DATASET_ROOT]
        │   ├── train_DVD
        │   ├── test_DVD
        │   ├── train_nah
        │   ├── test_nah
        ```

        > **Note:**
        >
        > * `[DATASET_ROOT]` is currently set to `./datasets/video_deblur`. It can be specified by modifying [`config.data_offset`](https://github.com/codeslake/PVDNet/blob/main/configs/config.py#L42-43) in `./configs/config.py`.

3. **Pre-trained models**
    * Download and unzip [pretrained weights](https://www.dropbox.com/sh/frpegu68s0yx8n9/AACrptFFhxejSyKJBvLdk9IJa?dl=1) under `./ckpt/`:

        ```
        ├── ./ckpt
        │   ├── BIMNet.pytorch
        │   ├── PVDNet_DVD.pytorch
        │   ├── PVDNet_nah.pytorch
        │   ├── PVDNet_large_nah.pytorch
        ```

## Testing models of TOG2021

```shell
## Table 4 in the main paper (Evaluation on Su etal's dataset)
# Our final model 
CUDA_VISIBLE_DEVICES=0 python run.py --mode PVDNet_DVD --config config_PVDNet --data DVD --ckpt_abs_name ckpt/PVDNet_DVD.pytorch

## Table 5 in the main paper (Evaluation on Nah etal's dataset)
# Our final model 
CUDA_VISIBLE_DEVICES=0 python run.py --mode PVDNet_nah --config config_PVDNet --data nah --ckpt_abs_name ckpt/PVDNet_nah.pytorch

# Larger model
CUDA_VISIBLE_DEVICES=0 python run.py --mode PVDNet_large_nah --config config_PVDNet_large --data nah --ckpt_abs_name ckpt/PVDNet_large_nah.pytorch
```

> **Note:**
>
> * Testing results will be saved in `[LOG_ROOT]/PVDNet_TOG2021/[mode]/result/quanti_quali/[mode]_[epoch]/[data]/`.
> * `[LOG_ROOT]` is set to `./logs/` by default. Refer [here](https://github.com/codeslake/PVDNet/wiki/Log-Details) for more details about the logging.


* options
    * `--data`: The name of a dataset to evaluate: `DVD` | `nah` | `random`. Default: `DVD`
        * The data structure can be modified in the function [`set_eval_path(..)`](https://github.com/codeslake/PVDNet/blob/main/configs/config.py#L120-133) in `./configs/config.py`.
        * `random` is for testing models with any video frames, which should be placed as `[DATASET_ROOT]/random/[video_name]/*.[jpg|png]`. 

## Wiki
* [Logging](https://github.com/codeslake/PVDNet/wiki/Log-Details)
* [Training and testing details](https://github.com/codeslake/PVDNet/wiki/Training-&-Testing-Details)

## Evaluation
Following [Su *et al.*](https://www.dropbox.com/s/8daduee9igqx5cw/DVD.zip?dl=), to represent the ambiguity in the pixel location caused by blur, we measure PSNRs and SSIMs using the approach of [Koehler *et al.*](https://webdav.tuebingen.mpg.de/pixel/benchmark4camerashake/src_files/Pdf/Koehler_ECCV2012_Benchmark.pdf) that first aligns two images using global translation. Refer [here](https://github.com/codeslake/PVDNet/tree/main/evaluation) for more detail.

## Citation
If you find this code useful, please consider citing:
```
@artical{Son_2021_TOG,
    author = {Son, Hyeongseok and Lee, Junyong and Lee, Jonghyeop and Cho, Sunghyun and Lee, Seungyong},
    title = {Recurrent Video Deblurring with Blur-Invariant Motion Estimation and Pixel Volumes},
    journal = {ACM Transactions on Graphics},
    year = {2021}
}
```

## Contact
Open an issue for any inquiries.
You may also have contact with [sonhs@postech.ac.kr](mailto:sonhs@postech.ac.kr) or [junyonglee@postech.ac.kr](mailto:junyonglee@postech.ac.kr)

## Resources
All material related to our paper is available by following links:

| Link |
| :-------------- |
| [The main paper](https://dl.acm.org/doi/pdf/10.1145/3453720) |
| [Supplementary Files](https://www.dropbox.com/s/eoqfpw3cex4z652/supp.zip?dl=1) |
| [Checkpoint Files](https://www.dropbox.com/sh/frpegu68s0yx8n9/AACrptFFhxejSyKJBvLdk9IJa?dl=1) |
| [Su *et al* [2017]'s dataset](https://www.dropbox.com/s/8daduee9igqx5cw/DVD.zip?dl=1) ([reference](http://www.cs.ubc.ca/labs/imager/tr/2017/DeepVideoDeblurring/#dataset)) |
| [Nah *et al.* [2017]'s dataset](https://www.dropbox.com/s/5ese6qtbwy7fsoh/nah.zip?dl=1) ([reference](https://seungjunnah.github.io/Datasets/gopro)) |

## License
This software is being made available under the terms in the [LICENSE](LICENSE) file.

Any exemptions to these terms require a license from the Pohang University of Science and Technology.

## About Coupe Project
Project ‘COUPE’ aims to develop software that evaluates and improves the quality of images and videos based on big visual data. To achieve the goal, we extract sharpness, color, composition features from images and develop technologies for restoring and improving by using them. In addition, personalization technology through user reference analysis is under study.  
    
Please checkout other Coupe repositories in our [Posgraph](https://github.com/posgraph) github organization.

### Useful Links
* [Coupe Library](http://coupe.postech.ac.kr/)
* [POSTECH CG Lab.](http://cg.postech.ac.kr/)
