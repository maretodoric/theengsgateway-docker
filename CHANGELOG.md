# Changelog

## [0.5.0.1] - 10-09-2022
### ADDED
- Created images for armv7, armhf, i387

### CHANGED
- Changed version so that MAJOR.MINOR.PATCH.IMAGE part matches TheengsGateway version, last number (IMAGE) is Docker Image version. Example: 0.5.0.1 == TheengsGateway==0.5.0 ;; Docker Image==1
- build.sh : Added ability to choose custom path for .env
- Dockerfile : Separate layer for apt packages
- Dockerfile : Downgrade python to 3.9 due to cmake build issues on armv7

## [0.0.15] - 08-09-2022
### ADDED
- Started changelog

### CHANGED
- Bumped TheengsGateway version to v0.5.0
- build.sh : Added 5sec wait time in interactive mode
- build.sh : Added check for .env file
- Dockerfile : Explicitly set TheengsGateway==0.5.0
