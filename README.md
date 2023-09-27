# Concrete-Packing-Density-MPDM-Model

This project is my individual project that is developed for my thesis project in my civil engineering degree.

MacOS Packing Density Model (MPDM) is a 3D computational model with a binary mixture of the larger particles and smaller particles, 
it is a model for predicting the packing density in the random particle packing. The MPDM is developed by implementing the game engine called “SceneKit” in Swift programming language, 
the required operating system of the MPDM is the MacOS system. It can simulate the collision, rotation, friction and 
other physical movements of the particles due to gravity in the virtual environment, the simulation of the MPDM is much more accurate than the PPDM. 
Moreover, the MPDM simulates the particle packing in the 3D environment which is close to reality, while the PPDM can only simulate the 2D particle packing (disc packing).

The environment of the MPDM is composed of a 3D rigid container with a transparent background, a binary mixture of the larger particles and smaller particles 
is generated randomly at the top of the rigid container. After a mixing process (vibration) and the particle settlement, the packing density of the system, 
the number of larger particles and the number of smaller particles can be measured as well as the volumetric fractions of either the larger particles or the smaller particles.

<img width="1306" alt="CleanShot 2023-05-15 at 10 52 27@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/281fffcb-3671-468b-a77f-4cfd9afbfee3">

The MPDM has a systematic procedure to predict the packing density of the random particle packing. There are multiple different statuses to be used to define and control the process of the MPDM, they are designed for the larger particles-dominated situation. Those statuses are printed to the “Experiment Status” at the control menu during the entire experimental process, which also allows the user to manage the experiment status easily.


## Usage

This project aims to develop a 3D dry binary packing model for spheres in order to study for the loosening, wedging and wall effects. Computational model for these experiments are developed and conducted to understand the effect that packing density of the binary particles is depended on the size and volume ratios of the particles in random packing.

A great understanding and knowledge of particle packing is important and useful to the concrete industries. A good packing of concrete ingredients can improve the strength, durability and workability of the concrete member directly, which cannot be achieved by purely adjusting the water and cement ratio.


## Visuals

### Video Demonstration
https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/b5926509-6ab5-4adc-a135-a1572e9d601a


### Feature

Result demonstration feature of the MPDM
<img width="1307" alt="CleanShot 2023-05-15 at 10 23 18@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/5357c273-3fae-45e7-9d0b-b1cbb26755ca">

The interior monitoring feature of the MPDM
<img width="1305" alt="CleanShot 2023-05-15 at 11 33 23@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/72b3ceb3-b950-44c0-b207-dfc70394ff84">


### Comprehensive Procedure

The user interface of the MPDM
<img width="1305" alt="CleanShot 2023-05-15 at 11 01 59@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/03e91a36-4b15-4474-85a8-e3e9c8702b88">

Layer-by-layer generation of the big particles in the MPDM
<img width="1304" alt="CleanShot 2023-05-15 at 12 38 17@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/b99e09af-72c8-4284-8cf0-e677f4d54aeb">

Layer-by-layer generation of the small particles in the MPDM
<img width="1304" alt="CleanShot 2023-05-15 at 12 44 09@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/886f96f8-1894-4b88-b286-94c31b76022f">

Layer-by-layer vibration of the particles in the MPDM
<img width="1304" alt="CleanShot 2023-05-15 at 12 44 29@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/0cc4694b-f098-41a3-bae4-fd12e3243e6e">

End of the experiment in the MPDM
<img width="1304" alt="Completed experiment of MPDM" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/50f89949-e5fd-4652-961a-95db54b2a09d">


### Packing Density Calculation

Triple integration method of calculating the packing density for the particles inside a random cubic space
<img width="1308" alt="CleanShot 2023-05-17 at 01 57 10@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/ade3c47a-e761-4523-8cf4-777b8bc7b717">


### Xcode Development

The user interface development of the MPDM in Xcode
<img width="1695" alt="Xcode for MPDM" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/83c6d886-553a-4d58-90ee-c444445944cf">


## License
Developer: Weng Chong LAO

Project Name: MacOS Packing Density Model (MPDM)

<br/>
The University of Queensland

Faculty of Engineering, Architecture and Information Technology

Bachelor of Engineering (Honours)

Civil Engineering

<br/>
Thesis Project

CIVL4584 2023 Semester 1

Concrete Packing Density Experiment

Big Particle Dominated Case

<br/>
Thesis Report:
https://drive.google.com/file/d/1kYt8tZzQzIIAhf1cOUQxt3hvW-5Hmh5T/view


<br/>
## Reference

Charts Library
https://github.com/danielgindi/Charts.git
