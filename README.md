# Concrete-Packing-Density-MPDM-Model

This project is my individual project that is developed for my thesis project in my civil engineering degree.

MacOS Packing Density Model (MPDM) is a 3D computational model with a binary mixture of the larger particles and smaller particles, 
it is a model for predicting the packing density in the random particle packing. The MPDM is developed by implementing the game engine called “SceneKit” in Swift programming language, 
the required operating system of the MPDM is the MacOS system. It can simulate the collision, rotation, friction and 
other physical movements of the particles due to gravity in the virtual environment, the simulation of the MPDM is much more accurate than the PPDM. 
Moreover, the MPDM simulates the particle packing in the 3D environment which is close to reality, while the PPDM can only simulate the 2D particle packing (disc packing).

The environment of the MPDM is composed of a 3D rigid container with a transparent background, a binary mixture of the larger particles and smaller particles 
is generated randomly at the top of the rigid container. After a mixing process (vibration) and the particle settlement, the packing density of the system, 
number of larger particles and number of smaller particles can be measured as well as the volumetric fractions of either the larger particles or the smaller particles.

<img width="1306" alt="CleanShot 2023-05-15 at 10 52 27@2x" src="https://github.com/wengchonglao0124/Concrete-Packing-Density-MPDM-Model/assets/85862169/281fffcb-3671-468b-a77f-4cfd9afbfee3">

The MPDM has a systematic procedure to predict the packing density of the random particle packing. There are multiple different statuses to be used to define and control the process of the MPDM, they are design for the larger particles dominated situation. Those statuses are printed to the “Experiment Status” at the control menu during the entire experimental process, which also allow the user to manage the experiment status easily.
